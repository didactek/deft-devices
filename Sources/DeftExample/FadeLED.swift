//
//  FadeLED.swift
//
//
//  Created by Kit Transue on 2020-06-06.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

import LEDUtils
import ShiftLED


func twoSegmentFade(leds: ShiftLED, ledCount: Int) {
    let steps = 30
    let cycles = 20
    var left = LEDColor.randomSaturated()
    var middle = LEDColor.randomSaturated()
    var right = LEDColor.randomSaturated()
    for _ in 0 ..< cycles {
        let targetLeft = LEDColor.randomSaturated()
        let planLeft = left.fade(to: targetLeft, count: steps)
        left = targetLeft

        let targetMiddle = LEDColor.randomSaturated()
        let planMiddle = middle.fade(to: targetMiddle, count: steps)
        middle = targetMiddle

        let targetRight = LEDColor.randomSaturated()
        let planRight = right.fade(to: targetRight, count: steps)
        right = targetRight

        for i in 0 ..< planLeft.count {
            let momentaryLeft = planLeft[i]
            let momentaryRight = planRight[i]
            let momentaryMiddle = planMiddle[i]

            let fadeLeft = momentaryLeft.fade(to: momentaryMiddle, count: ledCount / 2)
            for (index, value) in fadeLeft.enumerated() {
                leds[index] = value
            }
            let fadeRight = momentaryMiddle.fade(to: momentaryRight, count: ledCount / 2)
            for (index, value) in fadeRight.enumerated() {
                leds[index + ledCount / 2] = value
            }
            leds.flushUpdates()
            usleep(30)
        }
    }
}
