//
//  SampleStructures.swift
//  CLCodableTests
//
//  Created by Zapko on 2019-11-11.
//

import Foundation
import CLCodable


// MARK: - Trivial structure

struct Dummy { }

extension Dummy: CLDecodable {

    init(clToken: CLToken) throws {}
}

extension Dummy: CLEncodable {

    func encode() throws -> CLToken {
        .structure(name: "dummy", slots: [:])
    }
}


// MARK: - Simple structure

struct Person {
    let name: String
    let age:  Int
}

extension Person: CLDecodable {

    init(clToken: CLToken) throws {

        guard case .structure(let structureName, let slots) = clToken else {
            let message = "Expected structure root, got: '\(clToken)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        guard "\(type(of: self))" == structureName else {
            let message = "Expected structure of type '\(type(of: self))', got: '\(clToken)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        guard let name = try slots["name"]?.string() else {
            throw CLReadError.missingValue(.init("name"))
        }

        self.name = name

        guard let age = try slots["age"]?.int() else {
            throw CLReadError.missingValue(.init("age"))
        }

        self.age = age
    }
}

extension Person: CLEncodable {

    func encode() throws -> CLToken {
        .structure(
            name: "\(Person.self)",
            slots: [
                "name" : .literal(name),
                "age" : .number("\(age)")
            ]
        )
    }
}


// MARK: - Nested structure

struct Couple {
    let one: Person
    let two: Person
}

extension Couple: CLDecodable {

    init(clToken: CLToken) throws {

        guard case .structure(let name, let slots) = clToken else {
            let message = "Expected structure root, got: '\(clToken)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        guard "\(type(of: self))" == name else {
            let message = "Expected structure of type '\(type(of: self))', got: '\(clToken)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        guard let one: Person = try slots["one"].map(Person.init(clToken:)) else {
            throw CLReadError.missingValue(.init("one"))
        }

        self.one = one

        guard let two: Person = try slots["two"].map(Person.init) else {
            throw CLReadError.missingValue(.init("two"))
        }

        self.two = two
    }
}

extension Couple: CLEncodable {

    public func encode() throws -> CLToken {
        .structure(
            name: "\(Couple.self)",
            slots: [
                "one" : try one.encode(),
                "two" : try two.encode()
            ]
        )
    }
}
