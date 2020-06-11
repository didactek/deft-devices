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


    // Set up the RunLoop:
    print("press RETURN to exit")
    FileHandle.standardInput.readInBackgroundAndNotify() // FIXME: later: use the data

    // Add a temperature record every second:
    let temperatureTracker = TimeAndTemperature()
    let sampleTemperature = Timer(timeInterval: 1, repeats: true) {_ in
        temperatureTracker.recordObservation(temperature: temp.temperature)
    }
    RunLoop.current.add(sampleTemperature, forMode: .default)

    // Fade the temperature display continuously:
    let temperatureDisplay = TemperatureOverTimeDisplay(leds: leds, ledCount: ledCount)
    let displayTemperature = Timer(timeInterval: 0.3, repeats: true) {_ in
        temperatureDisplay.update(history: temperatureTracker.averages())
    }
    RunLoop.current.add(displayTemperature, forMode: .default)

//    twoSegmentFade(leds: leds, ledCount: ledCount)
    RunLoop.current.run(mode: .default, before: Date.distantFuture)

    prideFlag(leds: leds, ledCount: ledCount)
    sleep(2)
    leds.clear()
}

