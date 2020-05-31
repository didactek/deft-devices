//
//  ShiftLED.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-30.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class ShiftLED {
    let count: Int
    let bus: LinuxSPI

    public init(bus: LinuxSPI, stringLength: Int) {
        count = stringLength
        self.bus = bus
    }

    public func all(red: Double, green: Double, blue: Double, current: Double) {
        let r8 = UInt8(red * 255)
        let g8 = UInt8(green * 255)
        let b8 = UInt8(blue * 255)

        let c5 = UInt8(current * 31)
        let c8 = c5 | 0b1110_0000

        var buffer = Data()

        // start: all zeros
        buffer.append(contentsOf: repeatElement(UInt8(0), count: 4))

        for _ in 0..<count {
            buffer.append(contentsOf: [c8, b8, g8, r8])
        }

        // end: all ones
        buffer.append(contentsOf: repeatElement(UInt8(0xff), count: 4))

        bus.write(data: buffer, count: buffer.count)
    }
}
