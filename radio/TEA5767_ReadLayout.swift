//
//  TEA5767_ReadLayout.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// datasheet at https://www.voti.nl/docs/TEA5767.pdf

class TEA5767_ReadLayout: BitStorageCore {
    struct Status {  // data obtained with read
        let ready = false
        let bandLimitReached = false
        let stereoTuned = false
    }
}
