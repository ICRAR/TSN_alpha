class MiscController < ApplicationController
  def advent
    if params["day"]
      @current_day = params["day"].to_i
    else
      start_day = Time.parse('14th, December 2013')
      now = Time.now
      @current_day = ((now - start_day)/1.day).to_i
    end

    render :advent, layout: false
  end
end