module Forecast
  @forecast = {}
  # Latitude and longitude for Buenos Aires (specifically Belgrano School), it could be done so that it has the latitude and longitude of
  # each user, and the dafault is this lat & long
  LATITUDE = "-34.563718"
  LONGITUDE = "-58.442460"

  def self.tweet_if_it_is_going_to_rain_today
    if Forecast.is_it_going_to_rain?("today")
      message = "It appears that it is going to rain today: "
      Forecast.it_is_going_to_rain_at.each do |hour, precipitation|
        message << "#{hour}: #{precipitation}% - "
      end
      SamTwitter.post(message)
    end
  end

  def self.tweet_todays_weather
    Forecast.update_forecast
    message = "The weather today at our school: #{@forecast.currently.summary}"
    SamTwitter.post(message)
  end

  def self.is_it_going_to_rain?(day)
    Forecast.update_forecast
    return false if @forecast.empty? #if API call failed

    return ((@forecast.daily.data[Forecast.get_day].precipProbability == 0) ? false : true)
  end

  def self.it_is_going_to_rain_at
    return nil unless Forecast.is_it_going_to_rain?("today")
    rain_at = {}
    
    #first 12 hours
    (0..11).each do |hour|
      if @forecast.daily.data[hour].precipProbability > 0
        rain_at << {"#{Time.at(@forecast.daily.data[hour].time).to_datetime.hour}" => "#{@forecast.daily.data[hour].precipProbability}"}
      end
    end

    rain_at
  end

  def self.get_day(day)
    if day == "today"
      0
    elsif day == "tomorrow"
      1
    else
      if Date::DAYNAMES.find_index(Date.today.strftime("%A")) > Date::DAYNAMES.find_index(day)
        7 - (Date::DAYNAMES.find_index(Date.today.strftime("%A")) - Date::DAYNAMES.find_index(day))
      else
        Date::DAYNAMES.find_index(day) - Date::DAYNAMES.find_index(Date.today.strftime("%A"))
      end
    end
  end

  def self.get_forecast_for(latitude, longitude)
    @forecast = ForecastIO.forecast(latitude, longitude, params: { units: 'si' })
    @forecast[:date] = Date.today
  end

  def self.update_forecast
    if @forecast.empty? || @forecast[:date] != Date.today
      Forecast.get_forecast_for(LATITUDE, LONGITUDE)
    end
  end
end