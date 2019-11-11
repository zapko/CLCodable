//
//  CLToken.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-10.
//

import Foundation



/// Shortcuts for types unwrapping methods
public extension CLToken {

    func string() throws -> String {
        switch self {
        case .literal(let string):
            return string

        default:
            let message = "Looking for literal, in '\(self)'"
            throw CLReadError.typeMismatch(.init(message))
        }
    }

    func int() throws -> Int {
        switch self {
        case .number(let raw):

            if let int = Int(raw) { return int }

            let message = "Malformed integer: '\(raw)'"
            throw CLReadError.dataCorrupted(.init(message))

        default:
            let message = "Looking for literal, in '\(self)'"
            throw CLReadError.typeMismatch(.init(message))
        }
    }

    func clStruct<T: CLDecodable>() throws -> T {

        switch self {
        case let .structure(name, slots):

            guard name.uppercased() == "\(T.self)".uppercased() else {
                let message = "Expecting '\(T.self)' read '\(name)'"
                throw CLReadError.typeMismatch(.init(message))
            }

            return try T(from: slots)

        default:
            let message = "Looking for literal, in '\(self)'"
            throw CLReadError.typeMismatch(.init(message))
        }
    }
}
