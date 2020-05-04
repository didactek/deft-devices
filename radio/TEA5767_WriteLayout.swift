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
    @position(SubByte(ofByte: 4, bit: 6))
    var standbyMode = false

    @position(SubByte(ofByte: 1, msb: 5, lsb: 0))
    var pllHi: UInt8 = 0

    @position(SubByte(ofByte: 2, msb: 7, lsb: 0))
    var pllLo: UInt8 = 0

    enum TuningMode: UInt8 {
        case search = 1
        case direct = 0
//        case preset  // documentation suggests presets, but is unclear on how they are set; and the computer probably is probably a nicer place to keep those anyway
    }
    @position(SubByte(ofByte: 2, bit: 6))
    var searchMode: TuningMode = .direct

    enum SearchDirection: UInt8 {
        case up = 1
        case down = 0
    }
    @position(SubByte(ofByte: 2, bit: 6))
    var searchDirection: SearchDirection = .up

    enum SearchStopLevel: UInt8 {
        case low = 0b01
        case medium = 0b10
        case high = 0b11
    }
    @position(SubByte(ofByte: 3, msb: 6, lsb: 5))
    var searchStopLevel: SearchStopLevel = .high

    struct Tuner {
        #if false  // the semantics from the clock table are more relevant to our use
        enum PLLRef: UInt8 {
            case mHz6_5
            case disabled
        }
        @position(SubByte(ofByte: 5, bit: 7))
        var pllRef: PLLRef = .mHz6_5

        enum DeemphasisTimeConstant: UInt8 {
            case μs75 = 1
            case μs50 = 0
        }
        @position(SubByte(ofByte: 5, bit: 6))
        var dtc: DeemphasisTimeConstant = .μs75
        #else
        enum Clock: UInt8 {  // combines PLLRef and XTAL
            case mHz13 = 0b00
            case kHz32_768 = 0b01
            case mHz6_5 = 0b10
            // 0b10 disallowed
        }
        @position(SubByte(ofByte: 5, msb: 7, lsb: 6))
        var clock: Clock = .kHz32_768
        #endif

        enum BandLimits: UInt8 {
            case japan = 1
            case us_europe = 0
        }
        @position(SubByte(ofByte: 4, bit: 5))
        var bandLimits: BandLimits = .us_europe
    }
    var tuner = Tuner()

    struct Audio {
        @position(SubByte(ofByte: 1, bit: 7))
        var muted = false

        @position(SubByte(ofByte: 3, bit: 3))
        var forcedMono = false
        @position(SubByte(ofByte: 3, bit: 2))
        var muteRight = false
        @position(SubByte(ofByte: 3, bit: 1))
        var muteLeft = false

        @position(SubByte(ofByte: 4, bit: 3))
        var softMute = false
        @position(SubByte(ofByte: 4, bit: 2))
        var highCutControl = false
        @position(SubByte(ofByte: 4, bit: 1))
        var stereoNoiseCancelling = false
    }
    var audio = Audio()
}
