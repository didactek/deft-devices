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
    history.recordObservation(temperature: sensor.temperature)

    let hot = LEDColor.randomSaturated()
    let cold = LEDColor.randomSaturated()
    let range = colorFade(from: cold, to: hot, count: resolution)

    for _ in 0 ..< 1000 {
        history.recordObservation(temperature: sensor.temperature)

        let observations = history.averages().suffix(ledCount)
        let lowTemp = observations.min()!
        let hiTemp = observations.max()!

        let indices = observations.map { (hiTemp == lowTemp) ? 0 : Int( Double(resolution) * ($0 - lowTemp) / (hiTemp - lowTemp)) }

        for (index, observation) in indices.enumerated() {
            leds[index] = range[observation]
        }
        leds.flushUpdates()
        usleep(300_000)
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

    var record: [Int : Averager] = [:]

    func recordObservation(temperature: Double, atTime: Date = Date()) {
        // FIXME: maybe clear entries rolling forward?
        let midnight = Calendar.current.startOfDay(for: atTime)
        let atMinute = Int(atTime.timeIntervalSince(midnight) / 2) // FIXME: 60

        if let accumulator = record[atMinute] {
            accumulator.record(entry: temperature)
        }
        else {
            record[atMinute] = Averager(firstValue: temperature)
        }
    }

    // FIXME: split by blocks of minutes
    func averages() -> [Double] {
        let sorted = record.sorted { kv1, kv2 in
            return kv1.key < kv2.key
        }
        return sorted.map {_, value in value.average() }
    }
}
