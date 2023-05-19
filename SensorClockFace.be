import json
import math
import util
import string

import BaseClockFace

var modes = ['illuminance']

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
        var suffix = ""

        if modes[self.modeIdx] == "illuminance"
            sensor_reading = string.format("%5i", sensorInfo['ANALOG']['Illuminance2'])
            suffix = "lx"
        end

        sensor_str = sensor_reading + suffix

        self.matrixController.print_string(sensor_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return SensorClockFace