require 'securerandom'

class LinksController < ApplicationController
  before_action :set_link, only: %i[ show destroy ]

  def index
    @links = Link.select { |x| x.link_id != nil }
  end

  def id_search
    @link = Link.find_by(link_id: params[:link_id])
    if !@link.nil?
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

  def create
    @link = Link.new(link_params.merge(link_id: SecureRandom.uuid))

    respond_to do |format|
      if @link.save
        format.html { redirect_to root_path, notice: "Link was successfully saved." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @link.destroy!

    respond_to do |format|
      format.html { redirect_to links_url, notice: "Link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_link
      @link = Link.find(params[:id])
    end

    def link_params
      params.require(:link).permit(:url, :link_id)
    end
end
