require "http"
require "json"
require "dotenv/load"

puts "======================================"
puts "   Will you need an umbrella today?"
puts "======================================"

puts "\nWhere are you?"
location = gets.chomp

puts "Checking the weather at #{location}...."

google_maps_api_key = ENV["GMAPS_KEY"]

google_maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location.gsub(" ", "%20")}&key=#{google_maps_api_key}"

google_maps_raw_response = HTTP.get(google_maps_url)

parsed_google_maps_response = JSON.parse(google_maps_raw_response)

results_hash = parsed_google_maps_response.fetch("results")

first_result = results_hash.at(0)

geometry_hash = first_result.fetch("geometry")

location_hash =  geometry_hash.fetch("location")

latitude = location_hash.fetch("lat")
longitude = location_hash.fetch("lng")

puts "Your coordinates are #{latitude}, #{longitude}."

pirate_weather_api_key = ENV["PIRATE_WEATHER_KEY"]

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_api_key}/#{latitude},#{longitude}"

raw_pirate_weather_response = HTTP.get(pirate_weather_url)

parsed_pirate_weather_response = JSON.parse(raw_pirate_weather_response)

currently_hash = parsed_pirate_weather_response.fetch("currently")

current_temp = currently_hash.fetch("temperature")

puts "It is currently #{current_temp}°F."

minutely_hash = parsed_pirate_weather_response.fetch("minutely", false)

if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")
  puts "Next hour: #{next_hour_summary}"
end

hourly_hash = parsed_pirate_weather_response.fetch("hourly")

next_twelve_hours_array = hourly_hash.fetch("data")[1..12]

precip_possible = false

next_twelve_hours_array.each do |hour|
  if hour.fetch("precipProbability") > 0.1
    precip_possible = true

    seconds_from_now = Time.at(hour.fetch("time")) - Time.now
    hours_from_now = seconds_from_now / 3600

    puts "In #{hours_from_now.round} hours, there is a #{(hour.fetch("precipProbability")*100).round}% chance of precipitation."
  end
end

if precip_possible
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end
