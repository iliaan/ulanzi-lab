import json
import math
import util

import BaseClockFace

var modes = ['rssi', 'ip', 'mac']

class NetClockFace: BaseClockFace
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
        var wifiInfo = tasmota.wifi()

        var x_offset = 1
        var y_offset = 1
        var wifi_str = "???"

        if wifiInfo["up"]
            if modes[self.modeIdx] == "q"
                var wifiQuality = str(wifiInfo["quality"])

                while size(wifiQuality) < 3
                    wifiQuality = " " + wifiQuality
                end

                x_offset += 3
                wifi_str = "WF " + wifiQuality + "%"
            end
            if modes[self.modeIdx] == "ip"
                wifi_str = wifiInfo["ip"]
                wifi_str = wifi_str + "   "
            end
            if modes[self.modeIdx] == "rssi"
                x_offset += 3
                wifi_str = str(wifiInfo["rssi"]) + " dBm"
            end
            if modes[self.modeIdx] == "mac"
                wifi_str = wifiInfo["mac"]
                wifi_str = wifi_str + "   "
            end
        else
            x_offset += 6
            wifi_str = "DOWN"
        end

        self.matrixController.print_long_string(wifi_str, x_offset, y_offset, true, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return NetClockFace