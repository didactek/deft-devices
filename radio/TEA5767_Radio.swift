//
//  TEA5767_radio.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class TEA5767_Radio: I2CTraits {
    static var defaultNodeAddress = 0x60

    static let intermediateFrequency: Double = 225_000
    static let referenceFrequency: Double = 32_768

    var writeBuffer = TEA5767_WriteLayout()
    var readBuffer = TEA5767_ReadLayout()
    let link: DataLink

    init(link: DataLink) {
        self.link = link
    }

    func executeRequests() {
        link.write(data: writeBuffer.storage.bytes)
    }

    func updateStatus() {
        link.read(data: &readBuffer.storage.bytes)
    }

    func tuneTo(mHz: Double) {
        writeBuffer.pll = Self.pll(mHz: mHz)
    }

    func tuning() -> Double {
        return Self.carrierMHz(highSideInjection: readBuffer.pll)
    }

    static func pll(mHz frequency: Double) -> Int {
        let highSideInjection = 4 * (frequency * 1e6 + intermediateFrequency) / referenceFrequency
        return Int(highSideInjection)
    }

    static func carrierMHz(highSideInjection: Int) -> Double {
        let frequency = (Double(highSideInjection) * referenceFrequency / 4) - intermediateFrequency
        return frequency / 1e6
    }
}



