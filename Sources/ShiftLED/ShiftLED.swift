//
//  ShiftLED.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-30.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

import DeftBus
import LEDUtils

public class ShiftLED {
    let count: Int
    let bus: LinkSPI

    public init(bus: LinkSPI, stringLength: Int) {
        count = stringLength
        self.bus = bus
    }



    func encode(color: LEDColor, current: Double) -> [UInt8] {
        let r8 = UInt8(clamping: Int(color.red * 255))
        let g8 = UInt8(clamping: Int(color.green * 255))
        let b8 = UInt8(clamping: Int(color.blue * 255))

        let c5 = UInt8(current * 31)
        let c8 = c5 | 0b1110_0000

        return [c8, b8, g8, r8]
    }

    public func all(color: LEDColor, current: Double) {
        var buffer = Data()

        // start: all zeros
        buffer.append(contentsOf: repeatElement(UInt8(0), count: 4))

        for _ in 0..<count {
            buffer.append(contentsOf: encode(color: color, current: current))
        }

        // end: all ones
        buffer.append(contentsOf: repeatElement(UInt8(0xff), count: 4))

        bus.write(data: buffer, count: buffer.count)
    }

    public func clear() {
        all(color: LEDColor(red: 0, green: 0, blue: 0), current: 0)
    }
}
