//
//  USFlag.swift
//
//
//  Created by Kit Transue on 2020-07-04.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

import ShiftLED
import LEDUtils

func usFlag(leds: ShiftLED, ledCount: Int) {
    for i in 0 ..< (ledCount / 2) {
        leds[i] = ((i % 4) == 3) ? .white : .blue
    }
    for i in (ledCount / 2) ..< ledCount {
        if (i % 8) >= 4 {
            leds[i] = .red
        } else {
            leds[i] = .white
        }
    }
    leds.flushUpdates()
}
