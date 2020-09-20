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

    public init(bus: LinkSPI, stringLength: Int, current: Double = 0.5) {
        count = stringLength
        self.bus = bus
        buffer = Data(repeating: 0, count: (count + 1) * 4)
        buffer.append(Data(repeating: 0xff, count: 4))
        self.current = current
    }

    func encode(color: LEDColor, current: Double) -> [UInt8] {
        let r8 = UInt8(clamping: Int(color.red * Double(UInt8.max)))
        let g8 = UInt8(clamping: Int(color.green * Double(UInt8.max)))
        let b8 = UInt8(clamping: Int(color.blue * Double(UInt8.max)))

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

    /// Set the curren /brigthness used for the entire string.
    ///
    /// - Parameter curreent: Fraction of full current (1.0).
    ///
    /// Will take effect at next update.
    /// - Note: Current is one of only 32 levels, so is not useful for controlling fades.
    /// You probably want to set-and-forget.
    public func setCurrent(current: Double) {
        assert(current >= 0, "current must be positive")
        assert(current <= 1.0, "current in range 0...1")
        self.current = current
    }

    public subscript(index: Int) -> LEDColor {
        get {
            assert((0 ..< count).contains(index), "range error")
            return decode(data: buffer.subdata(in: (index + 1) * 4 ..< (index + 2) * 4))
        }
        set {
            assert((0 ..< count).contains(index), "range error")
            buffer.replaceSubrange( ((index + 1) * 4) ..< ((index + 2) * 4), with: encode(color: newValue, current: current))
        }
    }

    public func flushUpdates() {
        bus.write(data: buffer)
    }

    public func all(color: LEDColor) {
        for index in 0..<count {
            self[index] = color
        }
        flushUpdates()
    }

    public func clear() {
        all(color: .black)
    }
}
