//
//  MCP9808_Registers.swift
//  radio
//
//  Created by Kit Transue on 2020-05-08.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

// FIXME FIXME FIXME!!!!
// DO NOT USE WITH SMBusWord IMPLEMENTATION!
// Chip speaks network byte order (big-endian).
// SMBus is little-endian.

import Foundation

// MCP9808 I2C temperature sensor
// datasheet at https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf
// datasheet version: DS25095A
// (The datasheet text and diagrams do not always agree about bit widths and
// other minor details. Diagrams are preferred in these conflicts.)

// FIXME: 8-bit
class MCP9808_PointerRegister: ByteArrayDescription {
    // REGISTER 5-1

    // Datasheet p.16
    enum RegisterPointer: UInt8, BitEmbeddable {
        // case reserved = 0b0000  // RFU, Reserved for Future Use (Read-Only register)
        case configuration = 0b0001  // Configuration register (CONFIG)
        case alertUpper = 0b0010  // Alert Temperature Upper Boundary Trip register (TUPPER)
        case alertLower = 0b0011  // Alert Temperature Lower Boundary Trip register (TLOWER)
        case critical = 0b0100  // Critical Temperature Trip register (TCRIT)
        case temperature = 0b0101  // Temperature register (TA)
        case manufacturerID = 0b0110  // Manufacturer ID register
        case deviceID = 0b0111  // Device ID/Revision register
        case resolution = 0b1000  // Resolution register
        // case reserved = 0b1xxx  // Reserved(1)
    }
    @Position(ofByte: 1, msb: 4, lsb: 0)
    var command: RegisterPointer = .temperature
}


class MCP9808_ConfigRegister: SMBusWord {
    // REGISTER 5-2
    // Datasheet p.18
    enum LimitHysteresis: UInt8, BitEmbeddable {
        case C0 = 0b00
        case C1_5 = 0b01
        case C3 = 0b10
        case C6 = 0b11
    }
    @Position(msb: 10, lsb: 9)
    var tHyst: LimitHysteresis = .C0

    enum PowerMode: UInt8, BitEmbeddable {
        case continuousConversion = 0
        case shutdown = 1
    }
    @Position(bit: 8)
    var shdn: PowerMode = .continuousConversion

    @Position(bit: 7)
    var criticalTemperatureLock = false

    @Position(bit: 6)
    var windowTemperatureLock = false

    enum InterruptClear: UInt8, BitEmbeddable {
        case noEffect = 0
        case clearInterruptOutput = 1
    }
    @Position(bit: 5)
    var intClear: InterruptClear = .noEffect

    @Position(bit: 4)
    var alertOutputStatus = false

    enum AlertControl: UInt8, BitEmbeddable {
        case disabled = 0
        case enabled = 1
    }
    @Position(bit: 3)
    var alertControl: AlertControl = .disabled

    enum AlertSelect: UInt8, BitEmbeddable {
        case upperLowerCrit = 0
        case critOnly = 1
    }
    @Position(bit: 2)
    var alertSelect: AlertSelect = .upperLowerCrit

    enum AlertPolarity: UInt8, BitEmbeddable {
        case activeLow = 0
        case activeHigh = 1
    }
    @Position(bit: 1)
    var alertPolarity: AlertPolarity = .activeLow

    enum AlertMode: UInt8, BitEmbeddable {
        case comparatorOutput = 0
        case interruptOutput = 1
    }
    @Position(bit: 0)
    var alertMode: AlertMode = .comparatorOutput
}

class MCP9808_TemperatureLimitRegister: SMBusWord {
    // REGISTER 5-3
    // Datasheet p.22

    // FIXME: this is a fixed-point fractional with two bits. @Position
    // doesn't support floats/fractionals, so we read all the bits and
    // will have to divide by 4 when interpreting as Celsius.
    // Alternatively, we could have read down to lsb 4 and ignored the
    // fractional part. Splitting them into decimal and fraction fields
    // is unwise because the fractional interpretation varies by the sign.
    @Position(msb: 12, lsb: 2, .extendNegativeBit)
    var temperatureQuarterCelsius: Int = 0
}

class MCP9808_AmbientTemperatureRegister: SMBusWord {
    // REGISTER 5-4
    // Datasheet p.24

    enum LimitFlag: UInt8, BitEmbeddable {
        case withinLimit = 0
        case outsideLimit = 1
    }

    @Position(bit: 15)
    var AmbientVsCritical: LimitFlag = .withinLimit

    @Position(bit: 14)
    var AmbientVsUpper: LimitFlag = .withinLimit

    @Position(bit: 13)
    var AmbientVsLower: LimitFlag = .withinLimit


    @Position(msb: 12, lsb: 0, .extendNegativeBit)
    var temperatureSixteenthCelsius: Int = 0
}

class MCP9808_ManufacturerIDRegister: SMBusWord {
    // REGISTER 5-5
    // Datasheet p.27
    @Position(msb: 15, lsb: 0)
    var manufacturerID: Int = 0x0054 // expected
}

class MCP9808_DeviceIDandRevisionRegister: SMBusWord {
    // REGISTER 5-6
    // Datasheet p.28

    @Position(msb: 15, lsb: 8)
    var deviceID: Int = 0

    @Position(msb: 7, lsb: 0)
    var revision: Int = 0
}

// FIXME: 8-bit
class MCP9808_ResolutionRegister: ByteArrayDescription {
    // REGISTER 5-7
    // Datasheet p.29

    enum Resolution: UInt8, BitEmbeddable {
        case c0_5    = 0b00  // +0.5°C (tCONV = 30 ms typical)
        case c0_25   = 0b01  // +0.25°C (tCONV = 65 ms typical)
        case c0_125  = 0b10  // +0.125°C (tCONV = 130 ms typical)
        case c0_0625 = 0b11  // +0.0625°C (power-up default, tCONV = 250 ms typical)
    }

    // FIXME: the MCP9808 is word-oriented, so the significant byte (known here
    // as "byte 1"; in the datasheet as "bits 8-15") is unused.
    // Don't forget the minor bits are in byte 2!
    @Position(ofByte: 1, msb: 1, lsb: 0)
    var deviceID: Resolution = .c0_0625
}




