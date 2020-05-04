//
//  DataLink.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class DataLink {
    func write(data: [UInt8]) {
        print(data.map { String(format: "0x%02x", $0) } )
    }

    func read( data: inout [UInt8]) {

    }
}
