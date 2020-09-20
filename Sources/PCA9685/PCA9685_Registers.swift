//
//  PCA9685_Registers   .swift
//
//
//  Created by Kit Transue on 2020-09-20.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftLayout

/// Mode Register 1 (MODE1)
///
/// Controller configuration: wake state, I2C addresses, and register addressing behavior.
///
/// - Note: [Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf) 7.3.1.
class ModeRegister1: ByteDescription {
    /// Restart  mode; see section 7.3.1.1. for procedure to get out of restart.
    @Position(bit: 7)
    var restartState: Bool = false

    /// Use external clock.
    @Position(bit: 6)
    var extclk: Bool = false

    /// Auto-increment (AI) enabled.
    @Position(bit: 5)
    var autoincrement: Bool = false

    /// Sleep: lower power mode; oscillator is off.
    @Position(bit: 4)
    var sleep: Bool = false

    /// Sub1 group address enabled
    @Position(bit: 3)
    var sub1: Bool = false

    /// Sub2 group address enabled
    @Position(bit: 2)
    var sub2: Bool = false

    /// Sub3 group address enabled
    @Position(bit: 1)
    var sub3: Bool = false

    /// All Call group address enabled
    @Position(bit: 0)
    var allCall: Bool = false
}
