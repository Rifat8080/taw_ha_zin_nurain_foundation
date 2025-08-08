class RemoveGuestImageFromEvents < ActiveRecord::Migration[8.0]
  def up
    # Remove guest_image attachments from events since guests now have individual images
    ActiveStorage::Attachment.where(
      record_type: 'Event',
      name: 'guest_image'
    ).destroy_all
  end

  def down
    # This is irreversible - we cannot restore deleted attachments
    # Individual guest images should be used instead
  end
end
