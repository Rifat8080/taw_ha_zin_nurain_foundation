class PagesController < ApplicationController
  layout "public"

  def about
  end

  def gallery
    # You can add/remove categories as needed. Images are loaded from app/assets/images/gallery/<category>/
    @gallery_categories = [
      {
        name: "Events",
        images: Dir.glob(Rails.root.join('app/assets/images/gallery/events/*.{jpg,jpeg,png,webp,gif}')).map { |f| "gallery/events/#{File.basename(f)}" }
      },
      {
        name: "Projects",
        images: Dir.glob(Rails.root.join('app/assets/images/gallery/projects/*.{jpg,jpeg,png,webp,gif}')).map { |f| "gallery/projects/#{File.basename(f)}" }
      },
      {
        name: "Volunteers",
        images: Dir.glob(Rails.root.join('app/assets/images/gallery/volunteers/*.{jpg,jpeg,png,webp,gif}')).map { |f| "gallery/volunteers/#{File.basename(f)}" }
      },
        {
        name: "Volunteers Gaza",
        images: Dir.glob(Rails.root.join('app/assets/images/gallery/volunteers_gaza/*.{jpg,jpeg,png,webp,gif}')).map { |f| "gallery/volunteers_gaza/#{File.basename(f)}" }
      }
    ]
    # Pagination logic: 25 images per page per category
    per_page = 25

    # Paginate each category's images robustly
    @gallery_categories.each_with_index do |cat, idx|
      total = cat[:images].size
      cat[:total_pages] = (total / per_page.to_f).ceil
      page_param = params["page_#{idx}"]&.to_i
      page_param = 1 if page_param.nil? || page_param < 1
      # If page_param is out of range, reset to 1
      if page_param > cat[:total_pages] && cat[:total_pages] > 0
        page_param = 1
      end
      cat[:current_page] = page_param
      cat[:images] = cat[:images].slice((page_param - 1) * per_page, per_page) || []
    end
  end
end
