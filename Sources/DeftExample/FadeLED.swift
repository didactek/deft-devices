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


class TwoSegmentFade {
    let fadeRange = 30 ..< 80
    let leds: ShiftLED
    let ledCount: Int

    var leftPlan: [LEDColor]
    var middlePlan: [LEDColor]
    var rightPlan: [LEDColor]

    init(leds: ShiftLED, ledCount: Int) {
        self.leds = leds
        self.ledCount = ledCount

        leftPlan = [LEDColor.randomSaturated()]
        middlePlan = [LEDColor.randomSaturated()]
        rightPlan = [LEDColor.randomSaturated()]
    }

    func update() {
        let left = leftPlan.removeFirst()
        if leftPlan.isEmpty {
            leftPlan = left.fade(to: LEDColor.randomSaturated(), count: Int.random(in: fadeRange))
        }
        let middle = middlePlan.removeFirst()
        if middlePlan.isEmpty {
            middlePlan = middle.fade(to: LEDColor.randomSaturated(), count: Int.random(in: fadeRange))
        }
        let right = rightPlan.removeFirst()
        if rightPlan.isEmpty {
            rightPlan = right.fade(to: LEDColor.randomSaturated(), count: Int.random(in: fadeRange))
        }


        let fadeLeft = left.fade(to: middle, count: ledCount / 2)
        for (index, value) in fadeLeft.enumerated() {
            leds[index] = value
        }
        let fadeRight = middle.fade(to: right, count: ledCount / 2)
        for (index, value) in fadeRight.enumerated() {
            leds[index + ledCount / 2] = value
        }
        leds.flushUpdates()
    }
}
