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
    var buffer: Data
    var current: Double

    public init(bus: LinkSPI, stringLength: Int) {
        count = stringLength
        self.bus = bus
        buffer = Data(repeating: 0, count: (count + 1) * 4)
        buffer.append(Data(repeating: 0xff, count: 4))
        current = 0.25
    }

    func encode(color: LEDColor, current: Double) -> [UInt8] {
        let r8 = UInt8(clamping: Int(color.red * 255))
        let g8 = UInt8(clamping: Int(color.green * 255))
        let b8 = UInt8(clamping: Int(color.blue * 255))

        let c5 = UInt8(current * 31)
        let c8 = c5 | 0b1110_0000

        return [c8, b8, g8, r8]
    }

    func decode(data: Data) -> LEDColor {
        //let current5 = data[0] & 0b0001_1111
        let blue8 = data[1]
        let green8 = data[2]
        let red8 = data[3]
        return LEDColor(red: Double(red8) / Double(UInt8.max),
                        green: Double(green8) / Double(UInt8.max),
                        blue: Double(blue8) / Double(UInt8.max))
    }

    subscript(index: Int) -> LEDColor {
        get {
            decode(data: buffer.subdata(in: (index + 1) * 4 ..< (index + 2) * 4))
        }
        set {
            buffer.replaceSubrange( ((index + 1) * 4) ..< ((index + 2) * 4), with: encode(color: newValue, current: current))
        }
    }

    public func all(color: LEDColor, current: Double) {
        self.current = current
        for index in 0..<count {
            self[index] = color
        }
        bus.write(data: buffer, count: buffer.count)
    }

    public func clear() {
        all(color: LEDColor(red: 0, green: 0, blue: 0), current: 0)
    }
}
