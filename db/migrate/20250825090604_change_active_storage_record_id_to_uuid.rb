class ChangeActiveStorageRecordIdToUuid < ActiveRecord::Migration[7.0]
  def change
    # Remove the old integer column
    remove_column :active_storage_attachments, :record_id

    # Add the new uuid column (allow NULLs at first)
    add_column :active_storage_attachments, :record_id, :uuid
  end
end
