//
//  MCP9808_Registers.swift
//  radio
//
//  Created by Kit Transue on 2020-05-08.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// MCP9808 I2C temperature sensor
// datasheet at https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf

class MCP9808_Registers: BitStorageCore {
    enum RegisterPointer: UInt8 {
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

    // FIXME: BitStorageCore needs some adjustment to have this work well as a map of 2-wide-bytes (or wider)

    enum LimitHysteresis: UInt8 {
        case C0 = 0b00
        case C1_5 = 0b01
        case C3 = 0b10
        case C6 = 0b11
    }
    @position(ofByte: 1, msb: 2, lsb: 1)
    var tHyst: LimitHysteresis = .C0

    enum PowerMode: UInt8 {
        case continuousConversion = 0
        case shutdown = 1
    }
    @position(ofByte: 1, bit: 0)
    var shdn: PowerMode = .continuousConversion

    @position(ofByte: 2, bit: 7)
    var criticalTemperatureLock = false

    @position(ofByte: 2, bit: 6)
    var windowTemperatureLock = false

    enum InterruptClear: UInt8 {
        case noEffect = 0
        case clearInterruptOutput = 1
    }
    @position(ofByte: 2, bit: 5)
    var intClear: InterruptClear = .noEffect

    @position(ofByte: 2, bit: 4)
    var alertOutputStatus = false

    enum AlertControl: UInt8 {
        case disabled = 0
        case enabled = 1
    }
    @position(ofByte: 2, bit: 3)
    var alertControl: AlertControl = .disabled

    enum AlertSelect: UInt8 {
        case upperLowerCrit = 0
        case critOnly = 1
    }
    @position(ofByte: 2, bit: 2)
    var alertSelect: AlertSelect = .upperLowerCrit

    enum AlertPolarity: UInt8 {
        case activeLow = 0
        case activeHigh = 1
    }
    @position(ofByte: 2, bit: 1)
    var alertPolarity: AlertPolarity = .activeLow

    enum AlertMode: UInt8 {
        case comparatorOutput = 0
        case interruptOutput = 1
    }
    @position(ofByte: 2, bit: 1)
    var alertMode: AlertMode = .comparatorOutput

    // FIXME: refactor format definition used in three registers
    // FIXME: need to be able to describe a signed number of bits
    // FIXME: should be a better way of spanning bytes
}
