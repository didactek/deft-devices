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
    func write(data: [UInt8], count: Int) {
        print(data.map { String(format: "0x%02x", $0) } )
    }

    final func write(data: [UInt8]) {
        write(data: data, count: data.count)
    }

    func read(data: inout [UInt8], count: Int) {
        print("not simulating data read")
    }

    final func read(data: inout [UInt8]) {
        read(data: &data, count: data.count)
    }
}
