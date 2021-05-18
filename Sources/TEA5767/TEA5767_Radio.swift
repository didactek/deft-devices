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

/// Communicate with a TEA5767 FM tuner over I2C.
///
/// The TEA5767 is an FM receiver previously manufactured by Philips/NXP but now discontinued. Boards
/// with clones of the chip seem readily available, though some functions may be missing or not fully
/// implemented by these chios.
///
/// The 2007 Revision 5 of the NXP datasheet may be found [here.](https://www.voti.nl/docs/TEA5767.pdf)
///
/// - Note: The TEA5767 has an interesting and somewhat uncommon access pattern. Any write is
/// interpreted as configuring settings; any read is interpreted as asking for configuration. In both cases,
/// no registers are named: instead, [up to] 5 bytes are transferred. Their semantics depend only on their
/// position in the sequence. See `TEA5767_ReadLayout` and `TEA5767_WriteLayout`.
/// - Note: Preset tuning is not implemented; feature seems sparsely documented.
public class TEA5767_Radio: I2CTraits {
    public static var defaultNodeAddress = 0x60
    public static var presenceStrategy: PresenceQuery = .readByte

    static let intermediateFrequency: Double = 225_000
    static let referenceFrequency: Double = 32_768

    var requestBuffer = TEA5767_WriteLayout()
    var statusBuffer = TEA5767_ReadLayout()
    let link: LinkI2C

    public init(link: LinkI2C) {
        self.link = link
    }

    /// Flush the settings pending in the writeBuffer to the device.
    public func executeRequests() {
        try! link.write(data: requestBuffer.storage.bytes)
    }

    /// Include tuning in the pending request.
    ///
    /// Requests are combined into a single write, which is not sent until `executeRequests` is called.
    ///
    /// - Parameter mHz: Desired frequency, in MHz.
    public func tuneTo(mHz: Double) {
        requestBuffer.pll = Self.pll(mHz: mHz)
    }

    // # Reading Status

    /// Get the current status of the radio. Status can then be interpreted using the specific status
    /// getters (ready, stereoTuned, etc.).
    ///
    /// The TEA5767 uses a slightly-unusual query pattern: rather than sending a register number (via
    /// I2C write) and then reading its value (I2C read), the TEA5767
    public func updateStatus() {
        try! link.read(data: &statusBuffer.storage.bytes)
    }

    /// The frequency (in MHz) reported in the last updateStatus
    public var tuning: Double {
        get { Self.carrierMHz(pll: statusBuffer.pll) }
    }

    /// Has the tuner settled on a requested frequency, found a station during scan,
    /// or reached the end of the band during a scan as of the last updateStatus?
    public var ready: Bool { get { statusBuffer.readyFlag } }

    /// Is the station tuned in stereo as of the last updateStatus?
    public var stereoTuned: Bool { get { statusBuffer.stereoTuned } }

    /// Compute the PLL value for high side injection tuning.
    ///
    /// - Parameter mHz: desired carrier tuning frequency, in MHz.
    /// - Returns: PLL value.
    ///
    /// Equation from [Datasheet](https://www.voti.nl/docs/TEA5767.pdf) Footnote 1 of Table 32.
    static func pll(mHz frequency: Double) -> Int {
        let highSideInjection = 4 * (frequency * 1e6 + intermediateFrequency) / referenceFrequency
        return Int(highSideInjection)
    }

    /// Compute the carrier tuning given a PLL setting and high side injection.
    ///
    /// - Parameter pll: The PLL setting using high side injection.
    /// - Returns: Carrier frequency, in MHz.
    ///
    /// This is the inverse of `pll`.
    static func carrierMHz(pll highSideInjection: Int) -> Double {
        let frequency = (Double(highSideInjection) * referenceFrequency / 4) - intermediateFrequency
        return frequency / 1e6
    }
}



