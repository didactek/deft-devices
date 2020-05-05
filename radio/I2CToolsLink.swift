//
//  I2CToolsLink.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class I2CToolsLink: DataLink {
    let busID: Int
    let nodeAddress: Int

    init(busID: Int, nodeAddress: Int) {
        self.busID = busID
        self.nodeAddress = nodeAddress  // FIXME: should there be additional protection here?
    }

    override func write(data: [UInt8], count: Int) {
        assert(count >= 0)
        assert(count <= data.count)

        let hexFormattedBytes = data.prefix(count).map{ String(format: "0x%02x", $0) }.joined(separator: " ")
        print("/usr/sbin/i2ctransfer -y \(busID) w\(count)@\(nodeAddress) \(hexFormattedBytes)")
    }

    override func read(data: inout [UInt8], count: Int) {
        assert(count >= 0)
        if (data.count < count) {
            let shortfall = count - data.count
            data.append(contentsOf: [UInt8](repeating: 0, count: shortfall))
        }
        print("#would absorb results of: i2ctransfer -y \(busID) r\(count)@\(nodeAddress)")
    }
}
