require "aws-sdk-s3"
require "zlib"

class SqliteBackupJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |e|
    NotificationMailer.sqlite_backup_failure(e).deliver_now
    raise e
  end

  def perform
    date       = Time.current.strftime("%Y%m%d")
    backup_tmp = Rails.root.join("tmp/production_#{date}.sqlite3").to_s
    gz_tmp     = "#{backup_tmp}.gz"

    sqlite_backup(Rails.root.join("storage/production.sqlite3").to_s, backup_tmp)
    gzip(backup_tmp, gz_tmp)
    s3_upload(gz_tmp, "backups/sqlite/production_#{date}.sqlite3.gz")
    s3_prune rescue Rails.logger.error("[SqliteBackupJob] prune failed: #{$!}")
  ensure
    FileUtils.rm_f([ backup_tmp, gz_tmp ])
  end

  private

  def sqlite_backup(source, destination)
    db = SQLite3::Database.new(source)
    db.execute("VACUUM INTO '#{destination}'") # 書き込み中でも安全なオンラインバックアップ
  ensure
    db&.close
  end

  def gzip(input_path, output_path)
    Zlib::GzipWriter.open(output_path) { |gz| gz.write(File.binread(input_path)) }
  end

  def s3_upload(file_path, key)
    File.open(file_path, "rb") { |f| s3.put_object(bucket: aws_bucket, key: key, body: f) }
    Rails.logger.info("[SqliteBackupJob] uploaded: #{key}")
  end

  def s3_prune
    cutoff = 30.days.ago.strftime("%Y%m%d")
    s3.list_objects_v2(bucket: aws_bucket, prefix: "backups/sqlite/").contents.each do |obj|
      date = obj.key[/\d{8}/]
      s3.delete_object(bucket: aws_bucket, key: obj.key) if date && date < cutoff
    end
  end

  def s3
    @s3 ||= Aws::S3::Client.new(region: ENV.fetch("AWS_REGION"))
  end

  def aws_bucket
    @aws_bucket ||= ENV.fetch("AWS_BUCKET")
  end
end
