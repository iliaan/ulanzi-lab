import fonts
import json
import math
import introspect

import MatrixController
import SecondsClockFace
import DateClockFace

var clockFaces = [
    SecondsClockFace,
    DateClockFace,
];

class ClockfaceManager
    var matrixController
    var brightness
    var color
    var currentClockFace
    var currentClockFaceIdx


    def init()
        print("ClockfaceManager Init");
        self.matrixController = MatrixController();

        self.brightness = 50;
        self.color = fonts.palette['white']

        self.matrixController.print_string("Hello :)", 3, 2, true, self.color, self.brightness)
        self.matrixController.draw()

        self.currentClockFaceIdx = 0
        self.currentClockFace = clockFaces[self.currentClockFaceIdx](self)

        tasmota.add_rule("Button1#State", / value, trigger, msg -> self.on_button_prev(value, trigger, msg))
        tasmota.add_rule("Button2#State", / value, trigger, msg -> self.on_button_action(value, trigger, msg))
        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end

    def on_button_prev(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)

        self.currentClockFaceIdx = (self.currentClockFaceIdx + (size(clockFaces) - 1)) % size(clockFaces)
        self.currentClockFace = clockFaces[self.currentClockFaceIdx](self)

        self.redraw()
    end

    def on_button_action(value, trigger, msg)
        var handleActionMethod = introspect.get(self.currentClockFace, "handleActionButton");

        if handleActionMethod != nil
            self.currentClockFace.handleActionButton()
        end
    end

    def on_button_next(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)

        self.currentClockFaceIdx = (self.currentClockFaceIdx + 1) % size(clockFaces)
        self.currentClockFace = clockFaces[self.currentClockFaceIdx](self)

        self.redraw()
    end


    # This will be called automatically every 1s by the tasmota framework
    def every_second()
        self.update_brightness_from_sensor();

        self.redraw()
    end

    def redraw()
        #var start = tasmota.millis()

        self.currentClockFace.render()
        self.matrixController.draw()

        #print("Redraw took", tasmota.millis() - start, "ms")
    end

    def update_brightness_from_sensor()
        var sensors = json.load(tasmota.read_sensors());
        var illuminance = sensors['ANALOG']['Illuminance2'];

        var brightness = int(10 * math.log(illuminance));
        if brightness < 10
            brightness = 10;
        end
        if brightness > 90
            brightness = 90;
        end
        # print("Brightness: ", self.brightness, ", Illuminance: ", illuminance);

        self.brightness = brightness;
    end

    def save_before_restart()
        # This function may be called on other occasions than just before a restart
        # => We need to make sure that it is in fact a restart
        if tasmota.global.restart_flag == 1 || tasmota.global.restart_flag == 2
            self.currentClockFace = nil;
            self.matrixController.change_font('MatrixDisplay3x5');
            self.matrixController.clear();

            self.matrixController.print_string("Reboot...", 0, 2, true, self.color, self.brightness)
            self.matrixController.draw();
            print("This is just to add some delay");
            print("   ")
            print("According to all known laws of aviation, there is no way a bee should be able to fly.")
            print("Its wings are too small to get its fat little body off the ground.")
            print("The bee, of course, flies anyway, because bees don't care what humans think is impossible")
        end
    end
end

return ClockfaceManager