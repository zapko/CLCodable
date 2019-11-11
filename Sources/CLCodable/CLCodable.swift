//
//  CLCodable.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-10.
//

import Foundation


public protocol CLDecodable {
    init(from slots: [String : CLToken]) throws
}

public protocol CLEncodable {
    func encode() throws -> CLToken
}

public typealias CLCodable = CLEncodable & CLDecodable


// MARK: - Reading (Decoding)

public func readStruct<T: CLDecodable>(clView: String) throws -> T {

    var tokenizer = CLTokenizer(clView: clView)

    guard let token = try tokenizer.nextToken() else {
        throw CLReadError.emptyView
    }

    switch token {
    case let .structure(name, slots):

        guard "\(T.self)".uppercased() == name.uppercased() else {
            let message = "Expected root: '\(T.self)'"
            throw CLReadError.wrongRoot(token, .init(message))
        }

        return try T(from: slots)

    default:
        let message = "Expected root: '\(T.self)'"
        throw CLReadError.wrongRoot(token, .init(message))
    }
}

public func readList<T: CLDecodable>(clView: String) throws -> [T] {

    var tokenizer = CLTokenizer(clView: clView)

    guard let token = try tokenizer.nextToken() else {
        throw CLReadError.emptyView
    }

    switch token {
    case let .cons(car, cdr):

        var result: [T] = [try car.clStruct()]

        func read(tail: CLToken?) throws {

            guard let tail = tail else { return }

            switch tail {
            case let .cons(car, cdr):
                result.append(try car.clStruct())
                try read(tail: cdr)
            default:
                let message = "Unhandled list structure. Was expecting 'cons', received '\(tail)'"
                throw CLReadError.typeMismatch(.init(message))
            }
        }

        try read(tail: cdr)

        return result

    default:
        let message = "Expected root: '\(T.self)'"
        throw CLReadError.wrongRoot(token, .init(message))
    }
}


// MARK: - Printing (Encoding)

public func printStruct<T: CLEncodable>(_ structure: T) throws -> String {
    return try structure.encode().print()
}


