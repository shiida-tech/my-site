require "rails_helper"

RSpec.describe SqliteBackupJob, type: :job do
  describe "#perform" do
    context "エラーが発生した場合" do
      before do
        allow_any_instance_of(described_class).to receive(:sqlite_backup).and_raise(RuntimeError, "テストエラー")
        allow(NotificationMailer).to receive_message_chain(:sqlite_backup_failure, :deliver_now)
      end

      it "失敗通知メールを送信する" do
        expect { described_class.perform_now }.to raise_error(RuntimeError)
        expect(NotificationMailer).to have_received(:sqlite_backup_failure).with(instance_of(RuntimeError))
      end
    end
  end
end
