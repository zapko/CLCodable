//
//  CLCodable.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-10.
//

import Foundation


public protocol CLDecodable {
    init(clToken token: CLToken) throws
}

public protocol CLEncodable {
    func encode() throws -> CLToken
}

public typealias CLCodable = CLEncodable & CLDecodable


// MARK: - Reading (Decoding)

public func clRead<T: CLDecodable>(_ view: String) throws -> T {

    var tokenizer = CLTokenizer(clView: view)

    guard let token = try tokenizer.nextToken() else {
        throw CLReadError.emptyView
    }

    return try T(clToken: token)
}


// MARK: - Printing (Encoding)

public func clPrint<T: CLEncodable>(_ structure: T) throws -> String {
    try structure.encode().print()
}


// MARK: - Array extension

extension Array: CLDecodable where Element: CLDecodable {

    public init(clToken: CLToken) throws {

        guard case .cons(let car, let cdr) = clToken else {
            let message = "Expected cons root, got: '\(clToken)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        var result: [Element] = [try Element(clToken: car)]

        func read(tail: CLToken?) throws {

            guard let tail = tail else { return }

            switch tail {
            case let .cons(car, .empty):
                result.append(try Element(clToken: car))

            case let .cons(car, cdr):
                result.append(try Element(clToken: car))
                try read(tail: cdr)

            default:
                let message = "Unhandled list structure. Was expecting 'cons', received '\(tail)'"
                throw CLReadError.typeMismatch(.init(message))
            }
        }

        try read(tail: cdr)

        self.init(result)
    }
}

extension Array: CLEncodable where Element: CLEncodable {

    public func encode() throws -> CLToken {

        try reversed().reduce(.empty) {
            .cons(try $1.encode(), $0)
        }
    }
}

