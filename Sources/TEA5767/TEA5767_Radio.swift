//
//  TEA5767_Radio.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftLayout
import DeftBus

public class TEA5767_Radio: I2CTraits {
    public static var defaultNodeAddress = 0x60

    static let intermediateFrequency: Double = 225_000
    static let referenceFrequency: Double = 32_768

    var writeBuffer = TEA5767_WriteLayout()
    var readBuffer = TEA5767_ReadLayout()
    let link: DataLink

    public var ready: Bool { get { readBuffer.readyFlag } }
    public var stereoTuned: Bool { get { readBuffer.stereoTuned } }

    public init(link: DataLink) {
        self.link = link
    }

    /// Flush the settings pending in the writeBuffer to the device.
    public func executeRequests() {
        link.write(data: writeBuffer.storage.bytes)
    }

    /// Get the current status of the radio
    ///
    /// Status can then be read using the specific status getters (ready, stereoTuned, etc.)
    public func updateStatus() {
        link.read(data: &readBuffer.storage.bytes)
    }

    /// Include the specified tuning in the pending request.
    ///
    /// Requests are combined into a single write, which is not sent until `executeRequests` is called.
    public func tuneTo(mHz: Double) {
        writeBuffer.pll = Self.pll(mHz: mHz)
    }

    /// Return the frequency (in MHz) reported in the last updateStatus
    public func tuning() -> Double {
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



