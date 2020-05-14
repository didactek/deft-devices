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
    func write(data: Data, count: Int) {
        print(data.map { String(format: "0x%02x", $0) } )
    }

    final func write(data: Data) {
        write(data: data, count: data.count)
    }

    func read(data: inout Data, count: Int) {
        print("not simulating data read")
    }

    final func read(data: inout Data) {
        read(data: &data, count: data.count)
    }
}
