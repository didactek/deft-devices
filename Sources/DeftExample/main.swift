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

if true {
    #if os(macOS)
    let pi = SSHTransport(hostname: "raspberrypi.local", username: "pi")
    defer { pi.stop() }

    //let radioLink = try! I2CToolsLink(transport: pi, busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)

    let tempLink = try! I2CToolsLink(transport: pi, busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    #else
    //let radioLink = FixmeI2C(busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress)

    class Dummy: ShellTransport {
        func send(_ command: String) {
            print(command)
        }

        func receive() -> String {
            return ("0x00 0x00\n")
        }
    }
    let echo = Dummy()
    let tempLink = try! I2CToolsLink(transport: echo, busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress)
    #endif


    //let radio = TEA5767_Radio(link: radioLink)
    let temp = MCP9808_TemperatureSensor(link: tempLink)

    var currentTemp = temp.readTemperature()
    print("Temperature is \(currentTemp) C")

#if false
    radio.tuneTo(mHz: 94.9)
    radio.executeRequests()

    radio.updateStatus()
    while !radio.ready {
        radio.updateStatus()
    }
    // I get nothing for stereoTuned or chipIdentification; I wonder if I have a counterfeit chip.
    sleep(1)
    radio.updateStatus()
    print(radio.stereoTuned)
    print("Radio tuned to \(radio.tuning()) MHz")

    currentTemp = temp.readTemperature()
    print("Temperature is \(currentTemp) C")
#endif
}
