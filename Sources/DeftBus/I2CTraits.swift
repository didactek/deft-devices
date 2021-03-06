//
//  I2CTraits.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum PresenceQuery {
    /// An SMBus no-data "write" (control/address byte followed by STOP).
    case quickWrite
    /// Ask to read; clock in only a single byte.
    case readByte
    /// Do not query the device.
    case doNotPing
}

/// Information about how a device uses an I2C bus.
///
/// Devices do not need to implement this protocol to be used with a `LinkI2C`, but by implementing
/// this protocol, they agree to provide static information that can be useful in establishing the transport on
/// the bus.
///
/// Currently requires an address, but could also be used to indicate the maximum bus speed supported,
/// or whether the device supports features like 10-bit addressing or faster bus modes.
public protocol I2CTraits {
    /// The factory-provided default node address for nodes of this type.
    ///
    /// Note that some chips provide means to change their default address via jumpers or programmable configuration.
    /// Different addresses may be used when establishing the communications `LinkI2C`.
    static var defaultNodeAddress: Int { get }

    /// Technique to use to see if the device is present on the bus.
    static var presenceStrategy: PresenceQuery { get }
}

extension I2CTraits {
    public static var presenceStrategy: PresenceQuery { get {.doNotPing} }
}
