//
//  main.swift
//
//
//  Created by Kit Transue on 2020-08-14.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// utilities
import DeftBus
import LEDUtils
import PlatformSPI

// the device:
import ShiftLED

do {
    let configurationGuru = PlatformDeviceBroker()
    let spi = try! configurationGuru.platformSPI(speedHz: 30_500)

    let ledCount = 73
    let leds = ShiftLED(bus: spi, stringLength: ledCount, current: 0.05)

    leds.clear()
    leds.all(color: .blue)
    leds[ledCount / 2] = .red
    leds.flushUpdates()

    sleep(5)
    leds.clear()
}

