module ProjectsHelper
  # Returns a safe image URL for an ActiveStorage attachment.
  # Tries to generate a variant URL when supported; falls back to the blob URL.
  # Caches the result briefly to avoid repeated variant generation.
  def safe_image_src(attachment, variant: { resize_to_limit: [ 1200, 720 ] })
    return nil unless attachment&.attached?

    blob = attachment.blob
    cache_key = [ "safe_image_src", blob.signed_id, variant ].join("/") rescue nil

    if cache_key && defined?(Rails) && Rails.respond_to?(:cache)
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) { compute_safe_image_src(attachment, variant) }
    else
      compute_safe_image_src(attachment, variant)
    end
  rescue => _e
    # On any unexpected error, return nil so callers can fallback gracefully
    nil
  end

  private

  def compute_safe_image_src(attachment, variant)
    return nil unless attachment&.attached?

    if attachment.variable?
      begin
        url_for(attachment.variant(variant))
      rescue => _e
        url_for(attachment)
      end
    else
      url_for(attachment)
    end
  end
end
module ProjectsHelper
end
