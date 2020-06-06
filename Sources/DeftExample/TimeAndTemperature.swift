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


func tempMonitorFade(sensor: MCP9808_TemperatureSensor, leds: ShiftLED, ledCount: Int) {
    let history = TimeAndTemperature()
    let resolution = 100
    let fadeSteps = 100
    history.recordObservation(temperature: sensor.temperature)

    var hotStart = LEDColor.randomSaturated()
    var coldStart = LEDColor.randomSaturated()
    while true {
        let hotTarget = LEDColor.randomSaturated()
        let coldTarget = LEDColor.randomSaturated()

        let hotRange = colorFade(from: hotStart, to: hotTarget, count: fadeSteps)
        let coldRange = colorFade(from: coldStart, to: coldTarget, count: fadeSteps)

        hotStart = hotTarget
        coldStart = coldTarget

        for fadeCycle in 0 ..< fadeSteps {
            let range = colorFade(from: coldRange[fadeCycle], to: hotRange[fadeCycle], count: resolution)
            history.recordObservation(temperature: sensor.temperature)

            let observations = history.averages().suffix(ledCount)
            let lowTemp = observations.min()!
            let hiTemp = observations.max()!

            let indices = observations.map { (hiTemp == lowTemp) ? 0 : Int( Double(resolution) * ($0 - lowTemp) / (hiTemp - lowTemp)) }

            for (index, observation) in indices.enumerated() {
                var i = observation
                if i < 0 {
                    print("out of range observation \(i) clamped to 0")
                    i = 0
                }
                if i >= resolution {
                    print("out of range observation \(i) clamped to \(resolution - 1)")
                    i = resolution - 1
                }
                leds[index] = range[observation]
            }
            leds.flushUpdates()
            usleep(300_000)
        }
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

    var record: [(time: Int, average: Averager)] = []

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
