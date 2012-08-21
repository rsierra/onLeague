class ClubFilesController < ApplicationController
  before_filter :only_xhr, only: [:show]

  def show
    @club_file = ClubFile.find params[:id]
    render layout: false
  end
end
