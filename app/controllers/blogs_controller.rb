
class BlogsController < ApplicationController
  before_action :set_blog, only: [ :show, :edit, :update, :destroy ]
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  layout :resolve_layout

  # Public actions
  def index
    @blogs = Blog.published
  end

  def show
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(blog_params)
    @blog.published_at ||= Time.current
    if @blog.save
      redirect_to @blog, notice: "Blog was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  # Purge selected images if user asked
  if params[:remove_image_ids].present?
    params[:remove_image_ids].each do |id|
      @blog.images.find(id).purge
    end
  end

  if @blog.update(blog_params.except(:images))
    # ✅ Append new images (if any)
    if blog_params[:images].present?
      @blog.images.attach(blog_params[:images])
    end

    redirect_to @blog, notice: "Blog was successfully updated."
  else
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    @blog.destroy
    redirect_to blogs_path, notice: "Blog was successfully deleted."
  end

  private

  def resolve_layout
    if %w[index show].include?(action_name)
      "public"
    else
      "authenticated"
    end
  end

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    permitted = params.require(:blog).permit(
      :title,
      :body,
      :author,
      :published_at,
      images: [] # multiple uploads
    )

    # ✅ Clean up empty file inputs
    if permitted[:images].is_a?(Array)
      permitted[:images] = permitted[:images].reject(&:blank?)
    end

    permitted
  end
end
