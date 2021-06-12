//
//  main.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-01.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// utilities
import DeftLog
import DeftBus
import LEDUtils

// interfaces
import PlatformSPI

// specific devices:
import MCP9808
import ShiftLED
import TEA5767
import PCA9685

extension RunLoop.Mode {
    static let temperature = Self("displayTemperature")
    static let fade = Self("displayFade")
    static let flag = Self("displayFlag")
}


enum LinkRequirement {
    case shiftLED(link: LinkSPI)
    case radio(link: LinkI2C)
    case thermometer(link: LinkI2C)
    case servo(link: LinkI2C)
}


func setupLinks() -> [LinkRequirement] {
    var connections: [LinkRequirement] = []

    let guru = PlatformDeviceBroker.shared

    #if true  // want I2C things instead of SPI things
    // (can choose only one of I2C, SPI provided by FTDI)

    if let radioLink = try? guru.findI2C(usingDefaultsFor: TEA5767_Radio.self) {
        connections.append(.radio(link: radioLink))
    }

    if let tempLink = try? guru.findI2C(usingDefaultsFor: MCP9808_TemperatureSensor.self) {
        connections.append(.thermometer(link: tempLink))
    }

    if let servoLink = try? guru.findI2C(usingDefaultsFor: PCA9685.self) {
        connections.append(.servo(link: servoLink))
    }

    #else // SPI
    if let spi = try? guru.platformSPI(speedHz: 1_000_000) {
        connections.append(.shiftLED(link: spi))
    }
    #endif

    return connections
}


// Pattern for UI modes:
// - decide on supported modes based on hardware that was scanned
// - a mode can render, background process, or update. Each aspect of the mode is optional
if #available(OSX 10.12, *) {  // FIXME: encode this in the Package requirements? Foundation....
    DeftLog.settings = [
        ("com.didactek", .debug),
    ]
    var radio: TEA5767_Radio? = nil
    var leds: ShiftLED? = nil
    var temp: MCP9808_TemperatureSensor? = nil
    var servo: PCA9685? = nil

    let ledCount = 73

    for connection in setupLinks() {
        switch connection {
        case .radio(let link):  // 5.1 radio bug
            radio = TEA5767_Radio(link: link)
        case .shiftLED(let link):
            leds = ShiftLED(bus: link, stringLength: ledCount, current: 0.05)
            leds!.clear()  // in case the LEDs are already lit
        case .thermometer(let link):
            temp = MCP9808_TemperatureSensor(link: link)
        case .servo(link: let link):
            servo = PCA9685(link: link)
        }
    }

    if let servo = servo {
        servo.set(channel: 15, value: 0.5)  // midpoint
    }

    if let radio = radio {
        radio.tuneTo(mHz: 94.9)
        radio.executeRequests()

        radio.updateStatus()
        while !radio.ready {
            radio.updateStatus()
        }

        print(radio.stereoTuned ? "in stereo" : "mono")
        print("Radio tuned to \(radio.tuning) MHz")
    }


    if let temp = temp {
        let currentTemp = temp.temperature
        print("Temperature is \(currentTemp) C")
    }


    // ////////////////////////////////////////////////
    // Set up the RunLoop:
    // ////////////////////////////////////////////////


    // Add a temperature record every second:
    if let temp = temp, let leds = leds {
        let temperatureTracker = TimeAndTemperature()
        let sampleTemperature = Timer(timeInterval: 1, repeats: true) {_ in
            temperatureTracker.recordObservation(temperature: temp.temperature)
        }
        RunLoop.current.add(sampleTemperature, forMode: .fade)
        RunLoop.current.add(sampleTemperature, forMode: .flag)
        RunLoop.current.add(sampleTemperature, forMode: .temperature)

        // Fade the temperature display continuously:
        let temperatureDisplay = TemperatureOverTimeDisplay(leds: leds, ledCount: ledCount)
        let displayTemperature = Timer(timeInterval: 0.3, repeats: true) {_ in
            temperatureDisplay.update(history: temperatureTracker.averages())
        }
        RunLoop.current.add(displayTemperature, forMode: .temperature)
    }

    // Or just random prettiness:
    if let leds = leds {
        let fadeDisplay = TwoSegmentFade(leds: leds, ledCount: ledCount)
        let displayFade = Timer(timeInterval: 0.03, repeats: true) {_ in
            fadeDisplay.update()
        }
        RunLoop.current.add(displayFade, forMode: .fade)
    }

    print("press RETURN to exit, or one of flag / temp / fade")
    var keepRunningInMode: RunLoop.Mode? = .temperature

    let _ = NotificationCenter.default
        .addObserver(forName: FileHandle.readCompletionNotification,
                     object: FileHandle.standardInput, queue: nil) { aboutWhat in
                        guard let data = aboutWhat.userInfo?[NSFileHandleNotificationDataItem] as? Data,
                            let string = String(bytes: data, encoding: .ascii) else {
                                fatalError("stdin reported data, but none present")
                        }
                        switch string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                        case "":
                            keepRunningInMode = nil
                        case "flag":
                            keepRunningInMode = .flag
                            if let leds = leds {
                                prideFlag(leds: leds, ledCount: ledCount)
                            }
                        case "temp":
                            keepRunningInMode = .temperature
                        case "fade":
                            keepRunningInMode = .fade
                        default: break
                        }
    }
    while let mode = keepRunningInMode {
        FileHandle.standardInput.readInBackgroundAndNotify(forModes: [.default, .fade, .flag, .temperature])
        RunLoop.current.run(mode: mode, before: Date.distantFuture)
    }

    if let leds = leds {
        leds.clear()
    }
}

