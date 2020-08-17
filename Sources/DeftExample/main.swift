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
import DeftBus
import LEDUtils

// interfaces
import LinuxSPI
#if os(macOS)
#else
import LinuxI2C
#endif
#if canImport(FTDI)
import FTDI
extension FtdiSPI : LinkSPI {
    // no work necessary
}
extension FtdiI2CDevice : DataLink {

}
#endif


// specific devices:
import MCP9808
import ShiftLED
import TEA5767  // 5.1 radio bug

extension RunLoop.Mode {
    static let temperature = Self("displayTemperature")
    static let fade = Self("displayFade")
    static let flag = Self("displayFlag")
}


enum LinkRequirement {
    case shiftLED(link: LinkSPI)
    case radio(link: DataLink)
    case thermometer(link: DataLink)
}


func setupLinks() -> [LinkRequirement] {
    var connections: [LinkRequirement] = []

    #if os(macOS)
    #if canImport(FTDI)
    if let bus = try? FtdiI2C() {
        if let radioLink = try? FtdiI2CDevice(bus: bus, address: TEA5767_Radio.defaultNodeAddress) {
            connections.append(.radio(link: radioLink))
        }

        if let tempLink = try? FtdiI2CDevice(bus: bus, address: MCP9808_TemperatureSensor.defaultNodeAddress) {
            connections.append(.thermometer(link: tempLink))
        }
    }
    let spi = try! FtdiSPI(speedHz: 1_000_000)
    connections.append(.shiftLED(link: spi))
    #else
    // For I2C devices, try using ssh to bridge to remote interface:
    if #available(OSX 10.15, *) {
        let pi = SSHTransport(destination: "pi@raspberrypi.local")

        // 5.1 radio bug
        if let radioLink = try? I2CToolsLink(transport: pi, busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress) {
            connections.append(.radio(link: radioLink))
        }

        if let tempLink = try? I2CToolsLink(transport: pi, busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress) {
            connections.append(.thermometer(link: tempLink))
        }
    }
    #endif

    // For SPI, try an FTDI FT232H if the library has been included
    #if canImport(FTDI)
    if let spi = try? FtdiSPI(speedHz: 1_000_000) {
        connections.append(.shiftLED(link: spi))
    }
    #endif
    #endif



    #if os(Linux)
    // 5.1 radio bug
    if let radioLink = try? LinuxI2C(busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress) {
        connections.append(.radio(link: radioLink))
    }
    if let tempLink = try? LinuxI2C(busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress) {
        connections.append(.thermometer(link: tempLink))
    }
    if let spi = try? LinuxSPI(busID: 0, speedHz: 30_500) {
        connections.append(.shiftLED(link: spi))
    }
    #endif

    return connections
}


// Pattern for UI modes:
// - decide on supported modes based on hardware that was scanned
// - a mode can render, background process, or update. Each aspect of the mode is optional
if #available(OSX 10.12, *) {  // FIXME: encode this in the Package requirements? Foundation....
    var radio: TEA5767_Radio? = nil
    var leds: ShiftLED? = nil
    var temp: MCP9808_TemperatureSensor? = nil

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
        }
    }

    // 5.1 radio bug
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

