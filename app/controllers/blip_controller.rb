class BlipController < ApplicationController
  def index
    @blips = Blip.all
  end

  def new
    @blip = Blip.new
  end

  def create
    @blip = Blip.new(blip_params)
    if @blip.save
      redirect_to blip_path(@blip.unique_url)
    else
      render :new
    end
  end

  def show
    @blip = Blip.find_by!(unique_url: params[:id])
  end

  private

  def blip_params
    params.require(:blip).permit(:content)
  end
end
