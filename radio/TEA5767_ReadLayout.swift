//
//  TEA5767_ReadLayout.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// datasheet at https://www.voti.nl/docs/TEA5767.pdf

class TEA5767_ReadLayout: BitStorageCore {
    @position(SubByte(ofByte: 1, msb: 5, lsb: 0))
    var pllHi: UInt8 = 0

    @position(SubByte(ofByte: 2, msb: 7, lsb: 0))
    var pllLo: UInt8 = 0

    // Labeled IF6-IF0 in format; symbol "PLL[13:8]" [sic] in description
    // Probably not important in practial usage.
    // See https://en.wikipedia.org/wiki/Superheterodyne_receiver
    @position(SubByte(ofByte: 3, msb: 6, lsb: 0))
    var ifCounterResult: UInt8 = 0

    @position(SubByte(ofByte: 4, msb: 7, lsb: 4))
    var adcLevel: UInt8 = 0

    @position(SubByte(ofByte: 4, msb: 3, lsb: 0))
    var chipIdentification: UInt8 = 0

    class Status {
        @position(SubByte(ofByte: 1, bit: 7))
        var ready = true

        @position(SubByte(ofByte: 1, bit: 6))
        var bandLimitReached = false

        @position(SubByte(ofByte: 3, bit: 7))
        var stereoTuned = false
    }
    var status = Status()
}
