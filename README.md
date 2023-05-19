# Ulanzi TC001 

<img src="https://templates.blakadder.com/assets/images/logo.svg" alt="Tasmota" width="300"/>

## Flash Tasmota firmware

### **Warning**: 
Flashing Tasmota firmware on your device may potentially brick or damage the device. It is important to proceed with caution and to understand the risks involved before attempting to flash the firmware. Please note that any modifications to the device's firmware may void the manufacturer's warranty and may result in permanent damage to the device. It is strongly recommended to thoroughly research the flashing process and to follow instructions carefully. The user assumes all responsibility and risk associated with flashing the firmware.

To install Tasmota firmware on the Ulanzi TC001, follow these steps:

1. Download the Tasmota firmware from the [official Tasmota website](http://ota.tasmota.com/tasmota32/release/).
2. Follow installation guide [here](https://templates.blakadder.com/ulanzi_TC001.html).
3. In the Tasmota web interface, go to "Consoles" and select "Console". Enter the command "Pixels 256" to enable the 256-pixel display mode.
4. Set the time zone via the console by entering the command "Timezone +2:00".
**********************
## Clock

To set up a clock on your Tasmota device, you need to follow these steps:

1. Go to the Tasmota web interface.
1. Click on "Consoles" and select "Manage File System".
1. Create a new file called `fonts.be` and add the contents from [fonts.be](fonts.be).
1. Create a new file called `printer.be` and add the contents from [printer.be](printer.be).
1. Create a new file called `weather.be` and add the contents from [weather.be](weather.be).
1. Create a new file called `clock.be` and add the contents from [clock.be](clock.be).
1. Create a new file (or edit existing one) called `autoexec.be` with the contents from [autoexec.be](autoexec.be).

![Ulanzi_Manage_File_system_Clock](doc/Ulanzi_Manage_File_system_Clock.png)

These files contain the necessary code to display a clock on the device. Once the files are created and saved, restart the device to apply the changes. The clock should now be visible on the device display.

## Clock Features
* Time/Date/Stopwatch display
* Temperature polled from https://open-meteo.com/
  * Internal temperature sensor may be affected by nearby heat sources within the device
* Humidity display - from internal sensor
* Dew Point calculation
* Battery level indication (Note: may require calibration and logic adjustments)
* Illumination sensor for automatic brightness adjustment

## Usage
The clock can be controlled using the buttons on the device:
* Use the left button (facing the device) to switch between Time/Date/Stopwatch display modes.
* Use the right button to switch between Temperature/Humidity/Due Point/Battery level display modes.
* Use the action button to change the color of the clock display. In stopwatch mode, the action button is used to start/stop the stopwatch.

**********************
## TODO Next

**********************
## Ideas
* Print text in running line : news/stocks
* Alarm Clock
* Pixel Art
* Snake
* Yes/No questions/trivia/game/ai
**********************
## Links
* https://github.com/aptonline/PixelIt_Ulanzi
* https://blakadder.com/esphome-pixel-clock/
* https://github.com/dhepper/font8x8
* https://github.com/Ameba8195/Arduino/blob/master/hardware_v2/cores/arduino/font5x7.h
* https://github.com/mikerr/codebug-arduino/blob/master/font4x5.h
* https://www.espruino.com/modules/Font4x4Numeric.js
* https://github.com/ninjablocks/arduino/blob/master/DMD/Font3x5.h
* https://open-meteo.com/en/docs