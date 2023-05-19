import json
import math
import string

import BaseClockFace

var modes = ['Illuminance2', 'Humidity', 'Temperature', 'DewPoint', 'Battery']

class SensorClockFace: BaseClockFace
    var clockfaceManager
    var matrixController
    var modeIdx

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();

        self.modeIdx = 0
    end

    def handleActionButton()
        self.modeIdx = (self.modeIdx + 1) % size(modes)
    end

    def render()
        self.matrixController.clear()
        var sensorInfo = json.load(tasmota.read_sensors())

        var x_offset = 2
        var y_offset = 1
        var sensor_str = "?????"

        var sensor_reading = ""
        var prefix = ""
        var suffix = ""

        if modes[self.modeIdx] == "Illuminance2"
            sensor_reading = string.format("%5i", sensorInfo['ANALOG']['Illuminance2'])
            suffix = "lx"
        elif modes[self.modeIdx] == "Humidity"
            sensor_reading = string.format("%3.1f", sensorInfo['SHT3X']['Humidity'])
            prefix = "RH"
            suffix = "%"
        elif modes[self.modeIdx] == "Temperature"
            sensor_reading = string.format("%3.1f", sensorInfo['SHT3X']['Temperature'])
            suffix = "C"
        elif modes[self.modeIdx] == "DewPoint"
            sensor_reading = string.format("%3.1f", sensorInfo['SHT3X']['DewPoint'])
            prefix = "DP"
            suffix = "C"
        elif modes[self.modeIdx] == "Battery"
            var value = sensorInfo['ANALOG']['A1']
            var valueUnit = '%'
            var min = 2000
            var max = 2600
            if value < min
                value = min
            end
            if value > max
                value = max
            end
            value = int(((value - min) * 100) / (max - min))

            sensor_reading = string.format("%3i", value)
            prefix = "BAT"
            suffix = "%"
        end

        sensor_str = prefix + sensor_reading + suffix

        self.matrixController.print_string(sensor_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return SensorClockFace