import json
import persist

class Weather
    var cl
    var last_update_time
    var weather_cache

    def init(name)
        self.cl = webclient()
        persist.latitude = persist.find('latitude', '47.37')
        persist.longitude = persist.find('longitude', '8.55')
        persist.save()
        print("Using latitude: " + persist.latitude + " longitude: " + persist.longitude)
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + persist.latitude + "&longitude=" + persist.longitude + "&current_weather=true&timezone=auto"
        self.cl.begin(url)

        self.last_update_time = 0
        self.weather_cache = nil
    end

    def get_weather()
        if self.weather_cache != nil
            if self.last_update_time + 60 > tasmota.rtc()['local']
                return self.weather_cache['current_weather']
            end
        end

        var r = self.cl.GET()
        self.last_update_time = tasmota.rtc()['local']
        if r == 200
            self.weather_cache = json.load(self.cl.get_string())
            return self.weather_cache['current_weather']
        else
            return nil
        end
    end
end

var weather = module("weather")
weather.weather = Weather()
return weather

# to override the default location
# import persist
# persist.latitude = '62.1'
# persist.longitude = '23.5'
# persist.save()