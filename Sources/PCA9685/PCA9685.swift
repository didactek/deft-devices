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


/// Manage a PCA9685 PWM LED/servo controller on an I2C bus.
///
/// This board provides 16 PWM outputs with 12-bit resolution with configurable clock speed.
/// - Note: [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf)
public class PCA9685 {
    /// Base address; hardware jumpers offset from here.
    ///
    ///[Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.1.1 Regular I2C-bus slave address.
    public static let baseAddress = 0x40

    /// Address that all drivers of this type will repspond to, if enabled.
    ///
    /// [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.1.1 All Call address is reserved.
    public static let allCallAddress = 0b1110_000

    /// The number of PWM outputs on the controller.
    public static let channelCount = 16    // FIXME: this, along with set() should maybe be implemented as an array?


    // supported: Fast Mode+.
    let link: LinkI2C

    public init(link: LinkI2C) {
        self.link = link
        // configure clock

        let mode1 = ModeRegister1()
        mode1.autoincrement = true

        link.write(data: Data([0]) + mode1.storage.bytes)
    }

    public func set(channel: Int, value: Double) {
        guard channel >= 0 && channel < Self.channelCount else {
            fatalError("channel \(channel) out of range")
        }
        guard value >= 0 && value <= 1.0 else {
            fatalError("value \(value) out of normalized range")
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

import DeftLayout

/// Mode Register 1 (MODE1)
///
/// Controller configuration: wake state, I2C addresses, and register addressing behavior.
///
/// - Note: [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.3.1.
class ModeRegister1: ByteDescription {
    /// Restart  mode; see section 7.3.1.1. for procedure to get out of restart.
    @Position(bit: 7)
    var restartState: Bool = false

    /// Use external clock.
    @Position(bit: 6)
    var extclk: Bool = false

    /// Auto-increment (AI) enabled.
    @Position(bit: 5)
    var autoincrement: Bool = false

    /// Sleep: lower power mode; oscillator is off.
    @Position(bit: 4)
    var sleep: Bool = false

    /// Sub1 group address enabled
    @Position(bit: 3)
    var sub1: Bool = false

    /// Sub2 group address enabled
    @Position(bit: 2)
    var sub2: Bool = false

    /// Sub3 group address enabled
    @Position(bit: 1)
    var sub3: Bool = false

    /// All Call group address enabled
    @Position(bit: 0)
    var allCall: Bool = false
}
