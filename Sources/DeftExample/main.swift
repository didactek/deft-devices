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
//import TEA5767
import LinuxSPI

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

    //let radioLink = try! I2CToolsLink(transport: pi, busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)

    let tempLink = try! I2CToolsLink(transport: pi, busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    #else
    //let radioLink = try! LinuxI2C(busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)
    let tempLink = try! LinuxI2C(busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    #endif


    //let radio = TEA5767_Radio(link: radioLink)
    let temp = MCP9808_TemperatureSensor(link: tempLink)

    var currentTemp = temp.temperature
    print("Temperature is \(currentTemp) C")


    let spi = try! LinuxSPI(busID: 0, speedHz: 30_500)
    let leds = ShiftLED(bus: spi, stringLength: 72)
    for red in 0 ..< 256 {
        for green in 0 ..< 256 {
            for blue in 0 ..< 256 {
                leds.all(red: Double(red) / 256, green: Double(green) / 256, blue: Double(blue) / 256, current: 0.5)
                usleep(100)
            }
        }
    }

#if false
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
#endif
}
