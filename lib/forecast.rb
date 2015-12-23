class Forecast
  @@forecast = {}
  # Latitude and longitude for Buenos Aires (specifically Belgrano School), it could be done so that it has the latitude and longitude of
  # each user, and the dafault is this lat & long
  LATITUDE = "-34.563718"
  LONGITUDE = "-58.442460"

  def tweet_if_it_is_going_to_rain_today
    users = "@afalkear"
    if is_it_going_to_rain?("today")
      message = "#{users} :It appears that it is going to rain today: "
      it_is_going_to_rain_at.each do |hour, precipitation|
        message << "#{hour}hs: #{precipitation}% - "
      end
      SamTwitter.post(message)
    end
  end

  def tweet_todays_weather
    update_forecast
    message = "The weather today at our school: #{@@forecast.currently.summary} [#{Date.today}]"
    SamTwitter.post(message)
  end

  def is_it_going_to_rain?(day)
    update_forecast
    return false if @@forecast.empty? #if API call failed

    return ((@@forecast.daily.data[get_day(day)].precipProbability == 0) ? false : true)
  end

  def it_is_going_to_rain_at
    return nil unless is_it_going_to_rain?("today")
    rain_at = {}

    #first 12 hours
    (0..11).each do |hour|
      if @@forecast.hourly.data[hour] && @@forecast.hourly.data[hour].precipProbability > 0
        rain_at["#{Time.at(@@forecast.hourly.data[hour].time).to_datetime.hour}"] = "#{@@forecast.hourly.data[hour].precipProbability}"
      end
    end

    rain_at
  end

  def get_day(day)
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

  def get_forecast_for(latitude, longitude)
    @@forecast = ForecastIO.forecast(latitude, longitude, params: { units: 'si' })
    @@forecast[:date] = Date.today
  end

  def update_forecast
    if @@forecast.empty? || @@forecast[:date] != Date.today
      get_forecast_for(LATITUDE, LONGITUDE)
    end
  end
end
