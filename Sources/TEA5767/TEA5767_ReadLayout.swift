//
//  TEA5767_ReadLayout.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftLayout

// datasheet at https://www.voti.nl/docs/TEA5767.pdf

class TEA5767_ReadLayout: ByteArrayDescription {
    // Datasheet p.16
    @Position(ofByte: 1, bit: 7)
    var readyFlag = true

    @Position(ofByte: 1, bit: 6)
    var bandLimitReached = false

    @Position(significantByte: 1, msb: 5, minorByte: 2, lsb: 0)
    var pll: Int = 0

    // Datasheet p.17
    @Position(ofByte: 3, bit: 7)
    var stereoTuned = false

    // Labeled IF6-IF0 in format; symbol "PLL[13:8]" [sic] in description.
    // Probably not important in practial usage.
    // See https://en.wikipedia.org/wiki/Superheterodyne_receiver
    @Position(ofByte: 3, msb: 6, lsb: 0)
    var ifCounterResult: UInt8 = 0

    @Position(ofByte: 4, msb: 7, lsb: 4)
    var adcLevel: UInt8 = 0

    @Position(ofByte: 4, msb: 3, lsb: 1)
    var chipIdentification: UInt8 = 0
}
