class Api::V0::ForecastController < ApplicationController
  def check_for_rain
    f = Forecast.new
    f.tweet_if_it_is_going_to_rain_today

    render :json => "ok"
  end
end
