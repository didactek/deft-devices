//
//  PCA9685.swift
//
//
//  Created by Kit Transue on 2020-08-27.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Logging
import DeftBus

private var logger = Logger(label: "com.didactek.Deft.PCA0685")

/// Manage a PCA9685 PWM LED/servo controller on an I2C bus.
///
/// This board provides 16 PWM outputs with 12-bit resolution with configurable clock speed.
/// - Note: [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf)
/// - Bug: FIXME: This device may hold/delay the clock line during some requests (clock change, reset). I2C must monitor.
public class PCA9685: I2CTraits {
    // Traits:
    /// Product base address.
    /// - Note: PCA9685 address can be hardware set as high as 0x7F
    public static let defaultNodeAddress = 0x40

    public static let presenceStrategy: PresenceQuery = .quickWrite

    /// Base I2C address; hardware jumpers offset from here.
    ///
    ///[Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.1.1 Regular I2C-bus slave address.
    public static let baseAddress = 0x40

    /// Address that all drivers of this type will repspond to, if enabled.
    ///
    /// [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.1.1 All Call address is reserved.
    public static let allCallAddress = 0b1110_000

    /// The number of PWM outputs on the controller.
    public static let channelCount = 16    // FIXME: this, along with set() should maybe be implemented as an array?

    /// The first output register (LED0_ON_L)
    public static let outputRegisterBaseAddress: UInt8 = 0x06

    /// All channels off: (ALL_LED_OFF_H).
    ///
    /// See `stopPWM`;
    /// [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.3.4
    public static let allChannelMSBOffAddress: UInt8 = 0xfd

    /// PRE_SCALE register for setting the PWM frequency.
    ///
    /// [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.3.4
    let prescaleRegisterAddress: UInt8 = 0xfe

    /// The number of fragments in the clock cycle.
    ///
    /// On/off changes happen on these divisions according to the turn on time or turn off time of the channel.
    /// The number of divisions defines the PWM resolution (12 bit).
    static let clockDivisions = 1 << 12  // 4096

    // supported: Fast Mode+.
    let link: LinkI2C

    public init(link: LinkI2C) {
        if !link.supportsClockStretching() {
            // FIXME: what if link also exposed bus speed? We could make more useful
            // recommendations and issue stronger diagnostics here:
            logger.info("Bus does not support clock stretching (PCA9685 may stretch clock cycles)")
        }
        self.link = link

        setPWMClock(frequency: 1000)

        let mode1 = ModeRegister1()
        mode1.autoincrement = true

        writeRegister(startingAt: ModeRegister1.address, values: mode1.storage.bytes)
    }

    /// Write to a register.
    ///
    /// The controller is set to auto-increment mode in its intializer, so sending multiple bytes is possible.
    func writeRegister(startingAt address: UInt8, values: Data) {
        try! link.write(data: Data([address]) + values)
    }

    /// Change the value of a register by reading its current value, passing that
    /// to a transform function, then wrirting the transformed value to the register.
    ///
    /// - Parameter address: The register to read/write.
    /// - Parameter adjust: Trsnsform to use to convert the existing setting to a new value.
    func adjustRegisterValue(address: UInt8, adjust usingTransform: (UInt8) -> UInt8) {
        let oldValue = try! link.writeAndRead(sendFrom: Data([address]), receiveCount: 1)[0]

        let newValue = usingTransform(oldValue)
        writeRegister(startingAt: address, values: Data([newValue]))
        Thread.sleep(forTimeInterval: 0.05)
    }

    /// Set the clock.
    ///
    /// - Parameter frequency: desired fequency of PWM signal. Will clip to valid range  24...1526 Hz.
    ///
    /// - Note: This will temporarily put the device to sleep, creating a short period where it will not respond
    /// to commands. It signals this period by holding the clock. For links that don't support this clock stretching,
    /// this command is ignored: no PWM frequency change will be attempted.
    ///
    /// See [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.3.5 PWM frequency PRE_SCALE
    public func setPWMClock(frequency hz: Int) {
        guard link.supportsClockStretching() else {
            logger.info("Ignoring PWM clock change because link does not support clock stretching, and chip holds clock while moving into sleep mode prior to PWM adjustments.")
            return
        }

        let builtinOscillator = 25_000_000

        let computedPrescale = builtinOscillator / (Self.clockDivisions * hz) - 1

        let prescaleValue: UInt8
        if computedPrescale < 3 {
            prescaleValue = 3 // Might be enforced by hardware
        }
        else if computedPrescale > 0xff {
            prescaleValue = 0xff // clip
        } else {
            prescaleValue = UInt8(computedPrescale)
        }

        enterSleep()
        writeRegister(startingAt: prescaleRegisterAddress, values: Data([prescaleValue]))
        exitSleep()
    }

    /// Stop all channel output.
    ///
    /// - Important: This will clear/destroy all output values that have been set before this point.
    /// See Footnote 1 in [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.3.1.1:
    /// "The fastest [way to perform an orderly shutdown] is to write a logic 1 to bit 4 in register ALL_LED_OFF_H."
    func stopPWM() {
        writeRegister(startingAt: Self.allChannelMSBOffAddress, values: Data([0b0000_1000]))
    }


    func enterSleep() {
        // Stop all channels to avoid need for restart mode
        stopPWM()
        Thread.sleep(forTimeInterval: 0.05)

        adjustRegisterValue(address: ModeRegister1.address) {
            let register = ModeRegister1()
            register.storage.bytes[0] = $0
            register.sleep = true
            return register.storage.bytes[0]
        }
        Thread.sleep(forTimeInterval: 0.05)
    }

    func exitSleep() {
        adjustRegisterValue(address: ModeRegister1.address) {
            let register = ModeRegister1()
            register.storage.bytes[0] = $0
            register.sleep = false
            return register.storage.bytes[0]
        }
        Thread.sleep(forTimeInterval: 0.05)
    }

    public func set(channel: Int, value: Double) {
        guard (0 ..<  Self.channelCount).contains(channel) else {
            fatalError("channel \(channel) out of range")
        }
        guard (0.0 ... 1.0).contains(value) else {
            fatalError("value \(value) out of normalized range")
        }

        let valueMax = Self.clockDivisions - 1
        let onDuration = UInt16(Double(valueMax) * value)
        let offDuration = UInt16(valueMax) - onDuration
        let startTime = UInt16.random(in: 0 ... offDuration)
        let turnOffTime = startTime + onDuration

        let onBytes = withUnsafeBytes(of: startTime.littleEndian) {Data($0)}
        let offBytes = withUnsafeBytes(of: turnOffTime.littleEndian) {Data($0)}

        let register = UInt8(channel) * 4 + Self.outputRegisterBaseAddress

        writeRegister(startingAt: register, values: onBytes + offBytes)
    }
}
