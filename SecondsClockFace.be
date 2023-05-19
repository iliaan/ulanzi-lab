import BaseClockFace

class SecondsClockFace: BaseClockFace
    var clockfaceManager
    var matrixController

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();
    end

    def render()
        self.matrixController.clear()
        var rtc = tasmota.rtc()

        var time_str = tasmota.strftime('%H:%M:%S', rtc['local'])
        var x_offset = 2
        var y_offset = 1

        self.matrixController.print_string(time_str, x_offset, y_offset, true, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return SecondsClockFace