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
        case let .cons(car, cad):
            return ""
            
        case let .literal(literal):
            return "\"\(literal)\""
            
        case let .number(number):
            return number
            
        case let .structure(name, slots):
            
            let printedSlots = try slots.map {
                name, value in
                ":\(name.uppercased()) \(try value.print())"
            }
            
            return "#S(" + ([name.uppercased()] + printedSlots).joined(separator: " ") + ")"
        }
    }
}
