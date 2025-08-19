class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  layout :resolve_layout

  # ✅ Actions must be public (above private)
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
      redirect_to @blog, notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @blog.update(blog_params)
      redirect_to @blog, notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, notice: 'Blog was successfully deleted.'
  end

  private

  def resolve_layout
    if %w[index show].include?(action_name)
      'public'
    else
      'authenticated'
    end
  end

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :body, :author, :published_at, images: [])
  end
end
