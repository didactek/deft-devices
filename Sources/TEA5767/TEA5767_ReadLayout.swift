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

/// Layout of the how the TEA5767 responds to an I2C read. The device is stateless: any read will
/// return results in this layout.
///
/// See [datasheet](https://www.voti.nl/docs/TEA5767.pdf) Section 8.5: Reading data.
class TEA5767_ReadLayout: ByteArrayDescription {
    // Datasheet p.16

    /// Station has been found or band limit reached.
    @Position(ofByte: 1, bit: 7)
    var readyFlag = true

    /// Scanning has reached the end of the band.
    @Position(ofByte: 1, bit: 6)
    var bandLimitReached = false

    /// Setting of the PLL counter after search or direct tune.
    @Position(significantByte: 1, msb: 5, minorByte: 2, lsb: 0)
    var pll: Int = 0

    // Datasheet p.17

    /// Station is tuned in stereo.
    @Position(ofByte: 3, bit: 7)
    var stereoTuned = false

    /// "IF counter result". Probably not important in practical usage.
    ///
    /// Datasheed bug: labeled IF6-IF0 in format table; symbol "PLL[13:8]" [sic] in description.
    ///
    /// See https://en.wikipedia.org/wiki/Superheterodyne_receiver
    @Position(ofByte: 3, msb: 6, lsb: 0)
    var ifCounterResult: UInt8 = 0

    /// ADC level. Effectively: signal strength.
    @Position(ofByte: 4, msb: 7, lsb: 4)
    var adcLevel: UInt8 = 0

    /// Manufacturer populated data.
    /// - Note: May not be present.
    @Position(ofByte: 4, msb: 3, lsb: 1)
    var chipIdentification: UInt8 = 0
}
