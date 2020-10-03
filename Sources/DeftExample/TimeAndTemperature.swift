//
//  TimeAndDemperature.swift
//
//
//  Created by Kit Transue on 2020-06-06.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import LEDUtils
import MCP9808
import ShiftLED


class TemperatureOverTimeDisplay {
    let fadeSteps = 100
    let valueResolution = 100

    let leds: ShiftLED
    let ledCount: Int

    var minEndpointPlan: [LEDColor]
    var maxEndpointPlan: [LEDColor]

    init(leds: ShiftLED, ledCount: Int) {
        self.leds = leds
        self.ledCount = ledCount

        minEndpointPlan = [LEDColor.randomSaturated()]  // Enhancement: could evolve out of phase
        maxEndpointPlan = [LEDColor.randomSaturated()]
    }

    func update(history: [Double]) {
        let minEndpoint = minEndpointPlan.removeFirst()
        if minEndpointPlan.isEmpty {
            minEndpointPlan = minEndpoint.fade(to: LEDColor.randomSaturated(), count: fadeSteps)
        }
        let maxEndpoint = maxEndpointPlan.removeFirst()
        if maxEndpointPlan.isEmpty {
            maxEndpointPlan = maxEndpoint.fade(to: LEDColor.randomSaturated(), count: fadeSteps)
        }

        // map range
        let colorEncoding = minEndpoint.fade(to: maxEndpoint, count: valueResolution)
        let observations = history.suffix(ledCount)
        let lowValue = observations.min()!
        let hiValue = observations.max()!
        let indices = observations.map { (hiValue == lowValue) ? 0 : Int( Double(valueResolution - 1) * ($0 - lowValue) / (hiValue - lowValue)) }

        leds.replace(startingAt: 0, with: indices.map {colorEncoding[$0]})
        leds.flushUpdates()
    }
}


/// Log time and temperature and report averages over some period
class TimeAndTemperature {
    class Averager {
        var sampleCount: Int = 0
        var cumulative: Double = 0

        func record(entry: Double) {
            cumulative += entry
            sampleCount += 1
        }

        init(firstValue: Double) {
            record(entry: firstValue)
        }

        func average() -> Double {
            return cumulative / Double(sampleCount)
        }
    }

    private var record: [(time: Int, average: Averager)] = []

    func recordObservation(temperature: Double, atTime: Date = Date()) {
        let midnight = Calendar.current.startOfDay(for: atTime)
        let atMinute = Int(atTime.timeIntervalSince(midnight) / 2) // FIXME: 60

        if record.last?.time == atMinute {
            record.last!.average.record(entry: temperature)
        }
        else {
            while (record.count > 72) {  // FIXME: magic number
                let _ = record.removeFirst()
            }
            record.append((time: atMinute, average: Averager(firstValue: temperature)))
        }
    }

    func averages() -> [Double] {
        return record.map { $0.average.average() }
    }
}
