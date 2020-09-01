//
//  LinkSPI.swift
//
//
//  Created by Kit Transue on 2020-06-01.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Send messages over an SPI channel.
///
/// For this implementation, no 'read' is provided, either synchronously with the written data or via
/// a clock signal used just for reading.
public protocol LinkSPI {
    /// Send message over SPI.
    ///
    /// The write appears on the bus as just a stream of concatenated bits.
    ///
    /// With many hardware configurations, the driven device does not communicate back to the initiating device.
    /// No error checking is possible; all writes are assumed to succeed. Framing errors may be hard to diagnose.
    func write(data: Data)
}
