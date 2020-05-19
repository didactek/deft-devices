//
//  SSHLink.swift
//  radio
//
//  Created by Kit Transue on 2020-05-16.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Executes commands over an ssh session.
class SSHTransport: ShellTransport {
    let executable = URL(fileURLWithPath: "/usr/bin/ssh")
    let host = "raspberrypi.local"
    let user = "pi"
    // FIXME: should have timeouts on read and close...

    var commandPipe: FileHandle
    var receivePipe: FileHandle

    var process: Process

    init() {
        process = Process()
        process.executableURL = executable
        process.arguments = [ "\(user)@\(host)" ]

        let outgoing = Pipe()  // FIXME: hope that filehandles are not weak references to the pipe
        process.standardInput = outgoing.fileHandleForReading
        commandPipe = outgoing.fileHandleForWriting

        let incoming = Pipe()
        process.standardOutput = incoming.fileHandleForWriting
        receivePipe = incoming.fileHandleForReading

        try! process.run()

        // throw away the login/motd message
        let _ = receivePipe.availableData
    }

    func send(_ command: String) {
        let terminatedCommand = command.appending("\n")
        commandPipe.write(terminatedCommand.data(using: .ascii)!)
    }

    /// Read whatever is available from the pipe. Will wait until sender has flushed *some* data.
    func receive() -> String {
        return String(data: receivePipe.availableData, encoding: .ascii)!
    }

    func stop() {
        try? commandPipe.close()
//        process.terminate() // should probably give a timeout for waitUntilExit and then call this
        process.waitUntilExit()
    }
}