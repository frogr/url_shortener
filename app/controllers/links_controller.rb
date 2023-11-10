require 'securerandom'
require 'csv'

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
      @links = Link.where.not(link_id: nil).order(created_at: :desc).page(params[:page]).per(12)
    elsif current_user.role == "user"
      @links = Link.where(user_id: current_user.id).order(created_at: :desc).page(params[:page]).per(12)
    else
      render json: { error: "503, no links available for this role" }
    end
  end

  def export_to_csv
    @links = links_for_role

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "original_url", "shortened_url", "click_count" ]

      @links.each do |link|
        csv << [ link.url, full_url(link.slug), link.click_count]
      end
    end

    send_data csv_data, filename: "my_links.csv"
  end

  def full_url(slug)
    root_url.to_s + slug.to_s
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
