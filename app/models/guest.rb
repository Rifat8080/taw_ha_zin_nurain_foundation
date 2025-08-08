class Guest < ApplicationRecord
  belongs_to :event
  
  # Active Storage attachment for guest image
  has_one_attached :image
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :title, length: { maximum: 150 }, allow_blank: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
  
  # Custom validation for image
  validate :acceptable_image
  
  # Callback to handle image upload failures
  after_save :check_image_upload_errors
  
  # Scopes
  scope :with_images, -> { joins(:image_attachment).where.not(active_storage_attachments: { id: nil }) }
  scope :by_name, -> { order(:name) }
  
  private
  
  def acceptable_image
    return unless image.attached?
    
    begin
      # Check if the blob exists and is valid
      unless image.blob
        errors.add(:image, "failed to upload - please try again")
        return
      end
      
      # Check file size
      unless image.blob.byte_size <= 5.megabytes
        errors.add(:image, "is too big (should be at most 5MB)")
      end
      
      # Check file type
      acceptable_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
      unless acceptable_types.include?(image.blob.content_type)
        errors.add(:image, "must be a JPEG, PNG, GIF, or WebP file")
      end
      
      # Check if file is corrupted
      if image.blob.byte_size == 0
        errors.add(:image, "appears to be corrupted - please upload a different file")
      end
      
    rescue ActiveStorage::FileNotFoundError
      errors.add(:image, "file not found - upload may have failed")
    rescue ActiveStorage::IntegrityError
      errors.add(:image, "file integrity check failed - please re-upload")
    rescue StandardError => e
      Rails.logger.error "Guest image validation error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      errors.add(:image, "upload failed - please try again (#{e.message.first(50)})")
    end
  end
  
  def check_image_upload_errors
    return unless image.attached?
    
    begin
      # Try to access the blob to ensure it was uploaded correctly
      image.blob.byte_size
    rescue StandardError => e
      Rails.logger.error "Guest image upload verification failed: #{e.message}"
      errors.add(:image, "upload verification failed - please re-upload")
      false
    end
  end
end
