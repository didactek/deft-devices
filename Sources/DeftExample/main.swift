//
//  main.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-01.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

import DeftBus
import LEDUtils
import LinuxSPI

// specific devices:
import MCP9808
import ShiftLED
import TEA5767

extension RunLoop.Mode {
    static let temperature = Self("displayTemperature")
    static let fade = Self("displayFade")
    static let flag = Self("displayFlag")
}


#if os(macOS)
#else
import LinuxI2C
#endif

do {  // provide a scope for the ssh-availability guard
    #if os(macOS)
    guard #available(OSX 10.15, *) else {
        fatalError("Need a transport to connect to I2C, and ssh not available on this version of macOS")
    }
    let pi = SSHTransport(destination: "pi@raspberrypi.local")

    let radioLink = try! I2CToolsLink(transport: pi, busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)

    let tempLink = try! I2CToolsLink(transport: pi, busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    let spi = try! LinuxSPI(busID: 0, speedHz: 30_500)  // FIXME: just a stub that may compile; not a functional local or remote link.
    #else
    let radioLink = try! LinuxI2C(busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)
    let tempLink = try! LinuxI2C(busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    let spi = try! LinuxSPI(busID: 0, speedHz: 30_500)
    #endif

    #if false  // all radio code together:
    let radio = TEA5767_Radio(link: radioLink)
    radio.tuneTo(mHz: 94.9)
    radio.executeRequests()

    radio.updateStatus()
    while !radio.ready {
        radio.updateStatus()
    }

    print(radio.stereoTuned ? "in stereo" : "mono")
    print("Radio tuned to \(radio.tuning) MHz")
    #endif

    let temp = MCP9808_TemperatureSensor(link: tempLink)
    let currentTemp = temp.temperature
    print("Temperature is \(currentTemp) C")

    let ledCount = 73
    let leds = ShiftLED(bus: spi, stringLength: ledCount, current: 0.05)
    leds.clear()  // in case the LEDs are already lit

    // ////////////////////////////////////////////////
    // Set up the RunLoop:
    // ////////////////////////////////////////////////


    // Add a temperature record every second:
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

    // Or just random prettiness:
    let fadeDisplay = TwoSegmentFade(leds: leds, ledCount: ledCount)
    let displayFade = Timer(timeInterval: 0.03, repeats: true) {_ in
        fadeDisplay.update()
    }
    RunLoop.current.add(displayFade, forMode: .fade)

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
                            prideFlag(leds: leds, ledCount: ledCount)
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

    prideFlag(leds: leds, ledCount: ledCount)
    sleep(2)
    leds.clear()
}

