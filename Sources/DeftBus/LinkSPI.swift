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
public protocol LinkSPI {
    /// Send message over SPI.
    ///
    /// With many hardware configuration, the driven device does not communicate back to the initiating device.
    /// No error checking is possible; all writes are assumed to succeed. Framing errors may be hard to diagnose.
    func write(data: Data)
}
