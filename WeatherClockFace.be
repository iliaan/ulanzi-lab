import BaseClockFace
import Weather

class WeatherClockFace: BaseClockFace
    var clockfaceManager
    var matrixController
    var weather

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();

        self.weather = Weather.weather
    end

    def render()
        self.matrixController.clear()
        var weather = self.weather.get_weather()
        if nil == weather
            return
        end

        var value = weather['temperature']
        var valueUnit = ' C'
        var temp_str = str(value) + valueUnit + ' '
        var x_offset = 0
        var y_offset = 1
        self.matrixController.print_string(temp_str, x_offset, y_offset, true, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return WeatherClockFace