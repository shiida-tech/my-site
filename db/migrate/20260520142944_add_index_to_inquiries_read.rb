class AddIndexToInquiriesRead < ActiveRecord::Migration[8.1]
  def change
    add_index :inquiries, :read
  end
end
