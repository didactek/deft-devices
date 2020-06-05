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

import MCP9808
import TEA5767
import LEDUtils
import LinuxSPI
import ShiftLED


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
    #else
    let radioLink = try! LinuxI2C(busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)
    let tempLink = try! LinuxI2C(busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    #endif


    let radio = TEA5767_Radio(link: radioLink)
    let temp = MCP9808_TemperatureSensor(link: tempLink)

    var currentTemp = temp.temperature
    print("Temperature is \(currentTemp) C")


    let spi = try! LinuxSPI(busID: 0, speedHz: 30_500)
    let leds = ShiftLED(bus: spi, stringLength: 72, current: 0.3)


    var rng = SystemRandomNumberGenerator()
    var left = [0.0, 0.0, 0.0]
    var right = [0.0, 0.0, 0.0]
    for _ in 0 ..< 20 {
        let steps = 30

        let targetLeft: [Double] = [Double(rng.next(upperBound: UInt(256))) / 256, 1.0, 0.0,].shuffled()
        let planLeft = colorFade(from: LEDColor(values: left), to: LEDColor(values: targetLeft), count: steps)
        left = targetLeft

        let targetRight: [Double] = [Double(rng.next(upperBound: UInt(256))) / 256, 1.0, 0.0,].shuffled()
        let planRight = colorFade(from: LEDColor(values: right), to: LEDColor(values: targetRight), count: steps)
        right = targetRight

        for (momentaryLeft, momentaryRight) in zip(planLeft, planRight) {
            let fade = colorFade(from: momentaryLeft, to: momentaryRight, count: 72)
            for (index, value) in fade.enumerated() {
                leds[index] = value
            }
            leds.flushUpdates()
            usleep(30)
        }
    }
    leds.clear()

    radio.tuneTo(mHz: 94.9)
    radio.executeRequests()

    radio.updateStatus()
    while !radio.ready {
        radio.updateStatus()
    }

    sleep(1)
    radio.updateStatus()
    print(radio.stereoTuned ? "in stereo" : "mono")
    print("Radio tuned to \(radio.tuning) MHz")

    currentTemp = temp.temperature
    print("Temperature is \(currentTemp) C")
}

