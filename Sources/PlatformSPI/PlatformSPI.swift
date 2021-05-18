//
//  PlatformSPI.swift
//
//
//  Created by Kit Transue on 2021-04-12.
//  Copyright © 2021 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftBus
import SimpleUSB
import Logging

let logger = Logger(label: "com.didactek.deft-devices.platform")

// Use an interface based on what Package.swift is configured to use.
#if canImport(FTDI)
import FTDI
import PortableUSB
extension FtdiSPI : LinkSPI {
    // no work to do
}
extension FtdiI2CDevice : LinkI2C {
    // no work to do
}
#endif

#if canImport(DeftMCP2221)
import DeftMCP2221
extension DeftMCP2221: LinkI2C {
    // no work to do
}
#endif

#if os(Linux)
import LinuxSPI
import LinuxI2C
#endif

// FIXME: probably do not want command-line tools over ssh, so don't offer these:
//         let pi = SSHTransport(destination: "pi@raspberrypi.local")
//if #available(OSX 10.15, *) {
//    let pi = SSHTransport(destination: "pi@raspberrypi.local")
//
//    // 5.1 radio bug
//    if let radioLink = try? I2CToolsLink(transport: pi, busID: 1, nodeAddress: TEA5767_Radio.defaultNodeAddress) {
//        connections.append(.radio(link: radioLink))
//    }
//
//    if let tempLink = try? I2CToolsLink(transport: pi, busID: 1, nodeAddress: MCP9808_TemperatureSensor.defaultNodeAddress) {
//        connections.append(.thermometer(link: tempLink))
//    }
//}

enum platformError: Error {
    case noInterfaceFound
    case deviceNotFoundOnInterface
}

/// Factory to build devices as appropriate for the host OS.
///
/// - Note: This may not be the most efficient way to find a device: if the configuration of the platform
/// is known, it may be more efficient (and certainly more clear) to explicitly instantiate the transport components.
public class PlatformDeviceBroker {
    // This may be messy: the goal is to centralize all conditionals here.

    /// Singleton broker representing devices attached to this machine.
    public static var shared = PlatformDeviceBroker()

    #if canImport(FTDI)
    let ftdi: USBDevice?
    #endif

    private init() {
        #if canImport(FTDI)
        // usbBus might be more-generally useful, but keep
        // inside the conditional until that happens to reduce warnings when FTDI is not compiled in.
        let usbBus = PortableUSB.platformBus()
        ftdi = try? usbBus.findDevice(idVendor: Ftdi.defaultIdVendor, idProduct: Ftdi.defaultIdProduct)
        #endif
    }

    /// Convenience search pattern based on the I2CTraits defaults for a class.
    /// - Throws: If initializer throws or if subsequent ping on the link does not confirm a responsive device.
    public func findI2C(usingDefaultsFor nodeClass: I2CTraits.Type) throws -> LinkI2C {
        return try findI2C(nodeAddress: nodeClass.defaultNodeAddress,
                           checking: nodeClass.presenceStrategy)
    }

    /// Configure a link and ping device.
    /// - Parameter checking: Ping strategy to use to confirm device presence.
    /// - Throws: If link or ping fails.
    public func findI2C(nodeAddress: Int, checking: PresenceQuery) throws -> LinkI2C {
        return try findI2C(nodeAddress: nodeAddress).ping(strategy: checking)
    }

    /// Attempt to establish an I2C connection to node using known
    /// adapters on this computer.
    public func findI2C(nodeAddress: Int) throws -> LinkI2C {
        var interfaceFound = false
        // potential providers are:
        // FTDI 232H over USB
        // MCP2221 over HID
        // character special device on Linux

        #if canImport(FTDI)
        if let ftdiAttached = ftdi {
            interfaceFound = true
            if let busHost = try? FtdiI2C(ftdiAdapter: ftdiAttached) {
                if let adapter = try? FtdiI2CDevice(busHost: busHost, nodeAddress: nodeAddress) {
                    return adapter
                }
                else {
                    logger.debug("Did not find \(nodeAddress) attached to FTDI I2C bus.")
                }
            }
        } else {
            logger.trace("No FTDI found to provide I2C services")
        }
        #endif

        #if canImport(DeftMCP2221)
        // FIXME: differentiate between interface not found and node not on interface
        // if... {interfaceFound = true..}
        if let mcp = try? DeftMCP2221.init(nodeAddress: nodeAddress) {
            return mcp
        } else {
            logger.debug("Did not find \(nodeAddress) attached to MCP2221 I2C bus.")
        }
        #endif

        #if os(Linux)
        if let i2c = try? LinuxI2C(busID: 1, nodeAddress: nodeAddress) {
            logger.debug("I2C services provided by kernel using /dev/i2c- special device.")
            return i2c
        }
        #endif

        if !interfaceFound {
            throw platformError.noInterfaceFound
        }
        throw platformError.deviceNotFoundOnInterface
    }

    public func platformSPI(speedHz: Int) throws -> LinkSPI {
        #if canImport(FTDI)
        let usbSubsystem = PortableUSB.platformBus()
        if let ftdiDevice = try? usbSubsystem
            .findDevice(idVendor: Ftdi.defaultIdVendor,
                        idProduct: Ftdi.defaultIdProduct) {
            if let spi = try? FtdiSPI(ftdiAdapter: ftdiDevice, speedHz: speedHz) {
                logger.debug("SPI provided by FTDI.")
                return spi
            }
        } else {
            logger.trace("FTDI SPI adapter not found.")
        }
        #endif

        #if os(Linux)
        if let spi = try? LinuxSPI(busID: 1, speedHz: speedHz) {
            logger.debug("SPI provided by special device in /dev/")
            return spi
        }
        #endif

        throw platformError.noInterfaceFound
    }
}
