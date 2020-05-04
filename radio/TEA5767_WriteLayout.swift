//
//  TEA5767_WriteLayout.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


// datasheet at https://www.voti.nl/docs/TEA5767.pdf

class TEA5767_WriteLayout: BitStorageCore {
    // BYTE 1
    @position(SubByte(ofByte: 1, bit: 7))
    var muted = false

    enum TuningMode: UInt8 {
        case search = 1
        case direct = 0
        //        case preset  // documentation suggests presets, but is unclear on how they are set; and the computer probably is probably a nicer place to keep those anyway
    }
    @position(SubByte(ofByte: 1, bit: 6))
    var searchMode: TuningMode = .direct

    @position(SubByte(ofByte: 1, msb: 5, lsb: 0))
    var pllHi: UInt8 = 0


    // BYTE 2
    @position(SubByte(ofByte: 2, msb: 7, lsb: 0))
    var pllLo: UInt8 = 0


    // BYTE 3
    enum SearchDirection: UInt8 {
        case up = 1
        case down = 0
    }
    @position(SubByte(ofByte: 3, bit: 7))
    var searchDirection: SearchDirection = .up

    enum SearchStopLevel: UInt8 {
        case low = 0b01
        case medium = 0b10
        case high = 0b11
    }
    @position(SubByte(ofByte: 3, msb: 6, lsb: 5))
    var searchStopLevel: SearchStopLevel = .high

    enum LocalOscillatorInjection: UInt8 {
        case highSide = 1
        case lowSide = 0
    }
    @position(SubByte(ofByte: 3, bit: 4))
    var injection: LocalOscillatorInjection = .highSide

    @position(SubByte(ofByte: 3, bit: 3))
    var forcedMono = false

    @position(SubByte(ofByte: 3, bit: 2))
    var muteRight = false

    @position(SubByte(ofByte: 3, bit: 1))
    var muteLeft = false

    @position(SubByte(ofByte: 3, bit: 0))
    var softwareProgrammablePort1 = false


    // BYTE 4
    @position(SubByte(ofByte: 4, bit: 7))
    var softwareProgrammablePort2 = false

    @position(SubByte(ofByte: 4, bit: 6))
    var standbyMode = false

    enum BandLimits: UInt8 {
        case japan = 1
        case us_europe = 0
    }
    @position(SubByte(ofByte: 4, bit: 5))
    var bandLimits: BandLimits = .us_europe

    @position(SubByte(ofByte: 4, bit: 4))
    var xtal: UInt8 = 1

    @position(SubByte(ofByte: 4, bit: 3))
    var softMute = false

    @position(SubByte(ofByte: 4, bit: 2))
    var highCutControl = false

    @position(SubByte(ofByte: 4, bit: 1))
    var stereoNoiseCancelling = false

    // BYTE 5
    enum PLLRef: UInt8 {
        case mHz6_5 = 1
        case disabled = 0
    }
    @position(SubByte(ofByte: 5, bit: 7))
    var pllRef: PLLRef = .disabled

    enum DeemphasisTimeConstant: UInt8 {
        case μs75 = 1
        case μs50 = 0
    }
    @position(SubByte(ofByte: 5, bit: 6))
    var dtc: DeemphasisTimeConstant = .μs50

    // byte 5, bits 5-0 are unused
}
