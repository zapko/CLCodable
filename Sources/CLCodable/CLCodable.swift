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
