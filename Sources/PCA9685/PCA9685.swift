//
//  PCA9685.swift
//
//
//  Created by Kit Transue on 2020-08-27.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftBus

// https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf


/// Manage a PCA9685 PWM LED/servo controller on an I2C bus.
///
/// This board provides 16 PWM outputs with 12-bit resolution with configurable clock speed.
public class PCA9685 {
    public static let allCallAddress = 0b1110_000 // 7.1.1 Regular I2C-bus slave address
    // supported: Fast Mode+.

    static let channelCount = 16

    let link: LinkI2C

    public init(link: LinkI2C) {
        self.link = link
        // configure clock
        // enable auto-increment (write: 0, AI)
        link.write(data: Data([0, 0b0001_0000]))
    }

    public func set(channel: Int, value: Double) {
        guard channel >= 0 && channel < Self.channelCount else {
            fatalError("channel \(channel) out of range")
        }

        let valueMax = UInt16((1 << 11) - 1) // 12-bits; (or 0...4095)
        let onDuration = UInt16(Double(valueMax) * value)
        let offDuration = valueMax - onDuration
        let startTime = UInt16.random(in: 0 ... offDuration)
        let turnOffTime = startTime + onDuration

        let onBytes = withUnsafeBytes(of: startTime.littleEndian) {Data($0)}
        let offBytes = withUnsafeBytes(of: turnOffTime.littleEndian) {Data($0)}

        let register = Data([UInt8(channel) * 4 + 0x06])

        link.write(data: register + onBytes + offBytes)
    }
}
