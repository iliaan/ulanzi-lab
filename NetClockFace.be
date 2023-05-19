import json
import math
import util

import BaseClockFace

var pageSize = 8;
var pageDisplayTime = 2;

var modes = ['rssi', 'ip', 'mac']

class NetClockFace: BaseClockFace
    var clockfaceManager
    var matrixController
    var modeIdx
    var page
    var displayTimeCounter

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();

        self.modeIdx = 0
        self.page = 0
        self.displayTimeCounter = 0
    end

    def handleActionButton()
        self.modeIdx = (self.modeIdx + 1) % size(modes)
        self.page = 0
        self.displayTimeCounter = 0
    end

    def render()
        self.matrixController.clear()
        var wifiInfo = tasmota.wifi()

        var x_offset = 1
        var y_offset = 1
        var wifi_str = "???"
        var _pageSize = pageSize

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
            end
            if modes[self.modeIdx] == "rssi"
                x_offset += 3
                wifi_str = str(wifiInfo["rssi"]) + " dBm"
            end
            if modes[self.modeIdx] == "mac"
                wifi_str = wifiInfo["mac"]
                _pageSize += 1
            end
        else
            x_offset += 6
            wifi_str = "DOWN"
        end

        if size(wifi_str) > pageSize
            var splitStr = util.splitStringToChunks(wifi_str, _pageSize)
            wifi_str = splitStr[self.page]

            self.displayTimeCounter = (self.displayTimeCounter + 1) % (pageDisplayTime + 1)

            if self.displayTimeCounter == pageDisplayTime
                self.page = (self.page + 1) % size(splitStr)
            end
        else
            self.page = 0
            self.displayTimeCounter = 0
        end

        self.matrixController.print_string(wifi_str, x_offset, y_offset, true, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return NetClockFace