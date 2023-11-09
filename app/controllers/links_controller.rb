require 'securerandom'

class LinksController < ApplicationController
  before_action :set_link, only: %i[ show destroy ]

  def index
    @link = Link.new
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

  def profile
    @links = current_user.links
  end

  def create    
    if !current_user.nil?
      @link = current_user.links.new(link_params.merge(link_id: new_unique_id))
    else
      @link = Link.new(link_params.merge(link_id: new_unique_id))
    end

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
    def new_unique_id
      id = SecureRandom.uuid.last(10)

      link = Link.find_by(link_id: id)
      if link.nil?
        return id
      else
        new_unique_id
      end
    end

    def set_link
      @link = Link.friendly.find(params[:id])
    end

    def link_params
      params.require(:link).permit(:url, :link_id)
    end
end
