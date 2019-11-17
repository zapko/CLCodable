//
//  CLToken+Wrappers.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-11.
//

import Foundation



/// Shortcuts for wrapping methods
public extension CLToken {
    
    func print() throws -> String {
        switch self {
        case .empty:
            return "()"

        case let .cons(car, cdr):

            var listItems: [String] = [try car.print()]
            func printCar(iCdr: CLToken?) throws {

                guard let iCdr = iCdr else { return }

                switch iCdr {
                case let .cons(car, .empty):
                    listItems.append(try car.print())

                case let .cons(car, cdr):
                    listItems.append(try car.print())
                    try printCar(iCdr: cdr)

                default:
                    listItems.append(try iCdr.print())
                }
            }

            try printCar(iCdr: cdr)

            return "(\(listItems.joined(separator: " ")))"
            
        case let .literal(literal):
            let quotedLiteral = "\"\(literal)\""
            do {
                let data = try JSONEncoder().encode(quotedLiteral)
                guard let string = String(data: data, encoding: .utf8) else {
                    let message = "Failed to decode literal data for: '\(quotedLiteral)'"
                    throw CLPrintError.literalConversionFailed(.init(message))
                }
                return string
            } catch {
                throw CLPrintError.literalConversionFailed(.init("Literal encoding failed '\(quotedLiteral)'"))
            }

        case let .number(number):
            return number
            
        case let .structure(name, slots):
            
            let printedSlots = try slots.map {
                name, value in
                ":\(name.uppercased()) \(try value.print())"
            }
            
            return "#S(" + ([styleFromSwiftToCL(name: name)] + printedSlots).joined(separator: " ") + ")"
        }
    }
}
