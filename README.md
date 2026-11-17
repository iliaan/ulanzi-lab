# 🕰️ Ulanzi TC001 Pixel Clock (Tasmota)

A Berry-powered implementation for the Ulanzi TC001, transforming it into a smart, sensor-aware pixel clock.
This project leverages Tasmota's Berry scripting language to create a modular, object-oriented display system.

## ✨ Features

### 🖼️ Multi-Face Display System
Cycle through specialized information screens:
- **Digital Clock**: High-precision time display ('HH:MM:SS').
- **Calendar**: Date display ('DD.MM') with toggleable year view ('YYYY').
- **Live Weather**: Real-time temperature fetched from the Open-Meteo API.
- **Environment**: Real-time monitoring of:
    - ☀️ **Illuminance** (lx)
    - 💧 **Humidity** (%)
    - 🌡️ **Temperature** (°C)
    - ❄️ **Dew Point** (°C)
    - 🔋 **Battery Level** (%)
- **Network Monitor**: Diagnostics including **IP Address**, **MAC Address**, and **RSSI** (with auto-scrolling for long strings).

### 🧠 Smart Logic
- **Auto-Brightness**: The display brightness dynamically adjusts based on the ambient light sensor using a logarithmic scale.
- **Color Cycling**: Quickly change the theme of your clock by cycling through a curated color palette.
- **Efficient Networking**: Weather data is cached to minimize API calls and ensure smooth performance.

---

## 🚀 Installation

### ⚠️ Warning
Flashing custom firmware can brick your device and void your warranty. Proceed with caution.

### Step 1: Firmware Setup
1. Flash the Ulanzi TC001 with the latest **Tasmota32** firmware from the [official website](http://ota.tasmota.com/tasmota32/release/).
2. Configure the device using the [Blakadder Installation Guide](https://templates.blakadder.com/ulanzi_TC001.html).
3. **Required Console Commands**:
   Enter these commands in the Tasmota Console to prepare the hardware:
   ```bash
   Pixels 256        # Enable the 256-pixel matrix mode
   SetOption73 1    # Decouple buttons from relay/power controls
   Timezone +2:00    # Set your local timezone (replace +2:00 with your offset)
   ```

### Step 2: Deploying the Berry Scripts
1. Navigate to **Consoles** $\rightarrow$ **Manage File System**.
2. Create and upload the following files from this repository:
   - 'autoexec.be' (The main entry point)
   - 'ClockfaceManager.be' (The orchestrator)
   - 'MatrixController.be' (The hardware driver)
   - 'BaseClockFace.be' (The base class)
   - 'SecondsClockFace.be', 'DateClockFace.be', 'WeatherClockFace.be', 'SensorClockFace.be', 'NetClockFace.be' (The faces)
   - 'fonts.be' (Font bitmaps)
   - 'Weather.be' (API client)
   - 'util.be' (Utility functions)
3. Restart the device.

![Ulanzi TC001](doc/Ulanzi_Manage_File_system_Clock.png)

---

## 🎮 Usage & Controls

### Navigation
| Button | Action | Effect |
| :--- | :--- | :--- |
| **Left** | ⬅️ Previous | Switch to the previous Clock Face |
| **Right** | ➡️ Next | Switch to the next Clock Face |
| **Middle** | ⚙️ Action | Perform a face-specific action or cycle colors |

### Face-Specific Actions (Middle Button)
- **Clock/Weather**: Cycles through the color palette (White $\rightarrow$ Red $\rightarrow$ Green $\rightarrow$ Blue $\rightarrow$ Yellow).
- **Date**: Toggles between 'DD.MM' $\rightarrow$ 'YYYY'.
- **Sensors**: Cycles through 'Illuminance' $\rightarrow$ 'Humidity' $\rightarrow$ 'Temperature' $\rightarrow$ 'DewPoint' $\rightarrow$ 'Battery'.
- **Network**: Cycles through 'RSSI' $\rightarrow$ 'IP' $\rightarrow$ 'MAC'.

---

## 🛠️ Configuration

### Weather Location
The clock fetches weather data based on latitude and longitude. To change the location from the default (Switzerland):
1. Open the Tasmota Console.
2. Run the following commands:
   '''bash
   persist.latitude = 'YOUR_LATITUDE'
   persist.longitude = 'YOUR_LONGITUDE'
   persist.save()
   '''

---

## 🏗️ Architecture & Development

This project follows an Object-Oriented approach to make adding new faces trivial.

### Class Hierarchy
- **'MatrixController'**: Low-level abstraction for the WS2812C LEDs. Handles gamma correction, matrix mapping, and string rendering.
- **'BaseClockFace'**: An abstract base class that all faces inherit from.
- **'ClockfaceManager'**: The central hub. It manages the current active face, processes button interrupts, and handles the 'every_second()' update loop.

### Adding a New Face
To create a new display face:
1. Create a new class inheriting from 'BaseClockFace'.
2. Implement the 'render()' method to define what to draw.
3. (Optional) Implement 'handleActionButton()' for custom middle-button behavior.
4. Add your class to the 'clockFaces' array in 'ClockfaceManager.be'.

### File Overview
| File | Purpose |
| :--- | :--- |
| 'autoexec.be' | Initializes the 'ClockfaceManager' on boot. |
| 'ClockfaceManager.be' | Handles input, brightness sensing, and face switching. |
| 'MatrixController.be' | Manages the LED matrix, fonts, and gamma correction. |
| 'BaseClockFace.be' | Abstract base class for all display faces. |
| 'SecondsClockFace.be' | Implements the digital clock face. |
| 'DateClockFace.be' | Implements the calendar face. |
| 'WeatherClockFace.be' | Implements the weather temperature face. |
| 'SensorClockFace.be' | Implements the environment sensor face. |
| 'NetClockFace.be' | Implements the network diagnostic face. |
| 'Weather.be' | Asynchronous HTTP client for Open-Meteo API. |
| 'fonts.be' | Definition of 'TinyUnicode', 'MatrixDisplay3x5', and 'Glance' fonts. |
| 'util.be' | Shared helper functions for math and string manipulation. |

---

## 🙏 Acknowledgments
- Deep gratitude to [Hypfer/ulanzi-tc001-tasmota](https://github.com/Hypfer/ulanzi-tc001-tasmota) for the software design and hardware research.

## 🔗 Resources
- [Open-Meteo API Docs](https://open-meteo.com/en/docs)
- [Tasmota Berry Documentation](https://tasmota.github.io/docs/Berry/)
