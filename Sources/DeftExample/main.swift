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

    let ledCount = 72
    let leds = ShiftLED(bus: spi, stringLength: ledCount, current: 0.05)
    leds.clear()  // in case the LEDs are already lit

//    twoSegmentFade(leds: leds, ledCount: ledCount)
    tempMonitorFade(sensor: temp, leds: leds, ledCount: ledCount)
    prideFlag(leds: leds, ledCount: ledCount)
}

