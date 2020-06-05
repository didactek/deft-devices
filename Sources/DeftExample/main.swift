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
    let leds = ShiftLED(bus: spi, stringLength: ledCount, current: 0.3)

    twoSegmentFade(leds: leds, ledCount: ledCount)

    leds.clear()
}

func twoSegmentFade(leds: ShiftLED, ledCount: Int) {
    let steps = 30
    let cycles = 20
    var left = LEDColor.randomSaturated()
    var middle = LEDColor.randomSaturated()
    var right = LEDColor.randomSaturated()
    for _ in 0 ..< cycles {
        let targetLeft = LEDColor.randomSaturated()
        let planLeft = colorFade(from: left, to: targetLeft, count: steps)
        left = targetLeft

        let targetMiddle = LEDColor.randomSaturated()
        let planMiddle = colorFade(from: middle, to: targetMiddle, count: steps)
        middle = targetMiddle

        let targetRight = LEDColor.randomSaturated()
        let planRight = colorFade(from: right, to: targetRight, count: steps)
        right = targetRight

        for i in 0 ..< planLeft.count {
            let momentaryLeft = planLeft[i]
            let momentaryRight = planRight[i]
            let momentaryMiddle = planMiddle[i]

            let fadeLeft = colorFade(from: momentaryLeft, to: momentaryMiddle, count: ledCount / 2)
            for (index, value) in fadeLeft.enumerated() {
                leds[index] = value
            }
            let fadeRight = colorFade(from: momentaryMiddle, to: momentaryRight, count: ledCount / 2)
            for (index, value) in fadeRight.enumerated() {
                leds[index + ledCount / 2] = value
            }
            leds.flushUpdates()
            usleep(30)
        }
    }
}

