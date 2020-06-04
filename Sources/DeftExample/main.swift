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
import MCP9808
import TEA5767
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
    let leds = ShiftLED(bus: spi, stringLength: 72)


    var rng = SystemRandomNumberGenerator()
    var current = [0.0, 0.0, 0.0]
    for _ in 0 ..< 20 {
        let target: [Double] = [Double(rng.next(upperBound: UInt(256))) / 256, 1.0, 0.0,].shuffled()
        let steps = 100

        let delta = (0 ..< 3).map {i in
            (target[i] - current[i]) / Double(steps)
        }

        for step in 0 ..< steps {
            for i in 0 ..< 3 {
                current[i] += delta[i]
            }
            let rampLevel = sin(2.0 * .pi * Double(step) / Double(steps)) / 4 + 0.5
            leds.all(red: current[0] * rampLevel,
                     green: current[1] * rampLevel,
                     blue: current[0] * rampLevel,
                     current: 0.7 )
            usleep(60)
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

