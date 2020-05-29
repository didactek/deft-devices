//
//  I2CTraits.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol I2CTraits {
    /// The factory-provided default node address for nodes of this type.
    ///
    /// Note that some chips provide means to change their default address via jumpers or programmable configuration.
    /// Different addresses may be used when establishing the communications `DataLink`.
    static var defaultNodeAddress: Int { get }
    // maximum clock speed....
}
