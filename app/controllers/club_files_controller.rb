class ClubFilesController < ApplicationController
  def show
    @club_file = ClubFile.find params[:id]
    render layout: false
  end
end
