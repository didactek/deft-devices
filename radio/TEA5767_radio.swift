//
//  TEA5767_radio.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class TEA5767_Radio {
    var writeBuffer = TEA5767_WriteLayout()
    var readBuffer = TEA5767_ReadLayout()
    let link: DataLink

    init(link: DataLink) {
        self.link = link
    }

    func flush() {
        link.write(data: writeBuffer.storage.bytes)
    }

    // FIXME: inject tool to communciate on bus
    // init(bus: ...)

    static func pll(mHz frequency: Double) -> (UInt8, UInt8) {
        let intermediateFrequency: Double = 225_000
        let referenceFrequency: Double = 32_768
        let highSideInjection = 4 * (frequency * 1e6 + intermediateFrequency) / referenceFrequency

        let n = Int(highSideInjection)
        let split = n.quotientAndRemainder(dividingBy: 256)
        return (UInt8(split.quotient), UInt8(split.remainder))
    }
}



