require 'net/http'

# you can find CITY_ID here: https://openweathermap.org/find?q=
# Once you click on your city from the search results, the City ID will be the last part of the URL.
# Example: https://openweathermap.org/city/4119617  -- '4119617' is your City ID
city_ids = [2960991, 4180439]

# options: metric / imperial
UNITS   = 'metric'

# create free account on open weather map to get API key
API_KEY = '06d821a59d16e19210cd58089c3ae84f'

# set your locale here English - en, Russian - ru, Italian - it, Spanish - es (or sp), Ukrainian - uk (or ua), German - de, Portuguese - pt, Romanian - ro, Polish - pl, Finnish - fi, Dutch - nl, French - fr, Bulgarian - bg, Swedish - sv (or se), Chinese Traditional - zh_tw, Chinese Simplified - zh (or zh_cn), Turkish - tr, Croatian - hr, Catalan - ca
LOCALE = 'en'

SCHEDULER.every '1m', :first_in => 0 do |job|
  city_ids.each do |city_id|
    http = Net::HTTP.new('api.openweathermap.org')
    response = http.request(Net::HTTP::Get.new("/data/2.5/weather?id=#{city_id}&units=#{UNITS}&appid=#{API_KEY}&lang=#{LOCALE}"))

    next unless '200'.eql? response.code

    weather_data  = JSON.parse(response.body)
    detailed_info = weather_data['weather'].first
    current_temp  = weather_data['main']['temp'].to_f.round

    send_event("#{city_id}", { :temp => "#{current_temp} &deg;#{temperature_units}",
                            :condition => detailed_info['description'],
                            :title => "#{weather_data['name']}",
                            :color => color_temperature(current_temp),
                            :climacon => climacon_class(detailed_info['id'])})
  end
end


def temperature_units
  'metric'.eql?(UNITS) ? 'C' : 'F'
end

def color_temperature(current_temp)
  if UNITS == 'metric' # temperature is Celsius
    case current_temp.to_i
    when 30..100
      '#FF3300'
    when 25..29
      '#FF6000'
    when 19..24
      '#FF9D00'
    when 5..18
      '#18A9FF'
    else
      '#0065FF'
    end
  else # temperature is Fahrenheit
  	case current_temp.to_i
    when 92..200
      '#FF3300'
    when 80..91
      '#FF6000'
    when 65..79
      '#FF9D00'
    when 41..64
      '#18A9FF'
    else
      '#0065FF'
    end
  end
end

# fun times ;) legend: http://openweathermap.org/weather-conditions
def climacon_class(weather_code)
  case weather_code.to_s
  when /800/
    'sun'
  when /80./
    'cloud'
  when /2.*/
    'lightning'
  when /3.*/
    'drizzle'
  when /5.*/
    'rain'
  when /6.*/
    'snow'
  else
    'sun'
  end
end