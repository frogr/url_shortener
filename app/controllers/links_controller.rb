require 'securerandom'

class LinksController < ApplicationController
  before_action :set_link, only: %i[ show destroy ]
  after_action :track_link_click, only: :show

  def index
    @link = Link.new
    @links = links_for_role
    # @links = Link.where.not(link_id: nil).page(params[:page]).per(12)
  end

  def links_for_role
    if current_user.nil? || current_user.role == "admin"
      @links = Link.where.not(link_id: nil).page(params[:page]).per(12)
    elsif current_user.role == "user"
      @links = Link.where(user_id: current_user.id).page(params[:page]).per(12)
    else
      render json: { error: "503, no links available for this role" }
    end
  end

  def id_search
    @link = Link.find_by(link_id: params[:link_id])
    if @link.present?
      redirect_to link_url(@link)
    else
      render json: { error: "404, link not found" }, status: :not_found
    end
  end

  def show
    url = @link.url
    url = "https://#{url}" unless url.starts_with?('http://', 'https://')
    redirect_to url, allow_other_host: true
  end

  def new
    @link = Link.new
  end

  def profile
    @links = current_user.links
  end

  def create
    @link = current_user ? current_user.links.new(link_params) : Link.new(link_params)
    @link.link_id = new_unique_id

    respond_to do |format|
      if @link.save
        format.html { redirect_to root_path, notice: "Link was successfully saved." }
        ahoy.track "Link created", link_id: @link.id
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @link = current_user.links.friendly.find(params[:id])
    @link.destroy!
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def new_unique_id
    loop do
      id = SecureRandom.uuid.last(10)
      return id unless Link.exists?(link_id: id)
    end
  end

  def set_link
    @link = Link.friendly.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:url)
  end

  def track_link_click
    ahoy.track "Link clicked", link_id: @link
  end
end
