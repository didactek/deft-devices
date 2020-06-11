//
//  PrideFlag.swift
//
//
//  Created by Kit Transue on 2020-06-06.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

import ShiftLED
import LEDUtils

func prideFlag(leds: ShiftLED, ledCount: Int) {
    let colors: [LEDColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    let bandHeight = ledCount / colors.count
    for i in 0 ..< ledCount {
        var index = i / bandHeight
        if index >= colors.count { index = colors.count - 1 }
        leds[i] = colors[index]
    }
    leds.flushUpdates()
}
