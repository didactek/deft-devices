# Deft

DEvices from swiFT


A collection of modules for connecting small hardware to computers using the Swift programming language.


Goals:
- provide a framework for connecting small hardware
- maximize use and call-site readability
- encourage discovery
  - minimize use of external libraries
- avoid any root/sudo access
- exemplify unit-testable design
- support development on Mac and Raspberry Pi devices


Features:

Uses the DeftLayout library to bridge bit descriptions that are very close the device datasheets on the one side,
and then idiomatic Swift on the other. This mapping minimizes the need to use the raw bit operations, hardcoded masks, and other "magic" constants that many alternate implementations employ.


## Installation

On the Raspberry Pi:
1. Install Swift:
    https://github.com/uraimo/buildSwiftOnARM#prebuilt-binaries
1. Enable the I2C interface:
   https://www.raspberrypi.org/documentation/configuration/raspi-config.md
1. Clone this repository


It is possible to work with the codebase using Xcode on a Mac. Xcode provides fast compilation, sophisticated code completion, and built-in documentation support. Xcode should identify the directory structure as belonging to a Swift Pacakge and be able to compile and run.


## Usage

Look at DeftExample/main.swift. Adapt as desired.

'swift build' 'swift test' 'swift run'

The tests do not assume any hardware, but use mock objects and data to test the codebase.


## Supporting a new device

### Describe messages

The underlying encoded bytes of the message are represented by an AssembledMessage.

The DeftLayout module provides support for mapping particular bits in AssembledMessage Data to properties in a message object.


Typical hierarchy for a mapping class:

BitStorageCore  // manages the AssembledMessage
[ByteArray]Description // provides @Position wrappers that "make sense" for the representation
[UserClass]Layout // uses @Position wrappers to add properties of the message


#### Example: a packed, 5-byte message

The TEA5767 radio tuner has only one command, consisting of a write of 5 bytes. Its datasheet describes the bytes by byte index and bits within the 8-bit byte. The ByteArrayDescription best supports this longer  array with byte-oriented descriptions.

    class TEA5767_WriteLayout: ByteArrayDescription {
        enum SearchStopLevel: UInt8, BitEmbeddable {
            case low = 0b01
            case medium = 0b10
            case high = 0b11
        }
        @Position(ofByte: 3, msb: 6, lsb: 5)
        var searchStopLevel: SearchStopLevel = .high
        // ...
    }

#### Example: a 2-byte message as a big-endian word

The MCP9808 defines a number of different 1- or 2-byte messages. The 2-byte messages are documented in the datasheet as big-endian words. The WordDescription @Position wrappers idiomatically handle positioning bits between 0 and 15 and encode them to bytes with the expected endian-ness:

    class MCP9808_AmbientTemperatureRegister: WordDescription {
        enum LimitFlag: UInt8, BitEmbeddable {
            case withinLimit = 0
            case outsideLimit = 1
        }
        //...
        @Position(bit: 13)
        var AmbientVsLower: LimitFlag = .withinLimit
    
        @Position(msb: 12, lsb: 0, .extendNegativeBit)
        var temperatureSixteenthCelsius: Int = 0
    }

Because WordDescription describes precisely two bytes (or one word), its @Position structs do not offer byte or word index/offset.

### Using Message Layouts

For messages to send, set the properties to the desired values using your layout class, then get the assembled bytes via the `storage` property via the base class and send to the device.

For messages to read, populate the underlying AssembledMessage `storage` with bytes from the device, then read the properties via the layout class.

### Reading/writing data

Objects typically keep a reference to a DataLink object to use to exchange bytes with the device.

LinuxI2C and SSHTransport are alternate providers of DataLink services.

### Present a consumer-friendly abstraction of the device

This is a suggested pattern.

Get a DataLink object during initialization. Receiving a DataLink that is already configured with I2C bus ID and address makes it easier for consumers to choose their transport method.

If you want, your new class may adopt the `I2CTraits` protocol, which can be used to set up the DataLink with a default address.

Provide a natural interface to the device. The implementation can communicate to the device using its DataLink,
using messages transcoded using its Layout classes. The public interface to the device may choose to hide the details
of this implementation.


## Implementation

@Position wrappers adopt the CoderAdapter protocol, which requires they provide and set up a ByteCoder that it wires to the AssembledMessage storage.


## Sample Device Support

- MCP9808 temperature sensor
- TEA5767 FM tuner


## Remote I2C access

SSHTransport lets the library sent I2C commands to i2c-tools (specifically: i2ctransfer) over an ssh session. This allows all the Swift code be be developed/run on a large computer while talking to devices connected to the I2C bus on a Raspberry Pi.


## Issues

The Swift 5.1 compiler will crash if more than one property wrapper structure is defined in the application
with the same name, even when those structures are defined within the scope of different classes.

This appears fixed in 5.2, but Swift binaries are not yet available for the RPi.

There is a "swift-5.1" branch that pares down the sample application to a single BitStorageCore
subclass, and thus avoids this problem for demonstration purposes.
