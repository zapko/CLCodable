# CLCodable
Codable protocol for Common Lisp structures

![](https://github.com/zapko/CLCodable/workflows/Swift/badge.svg)
[![Build Status](https://travis-ci.org/zapko/CLCodable.svg?branch=develop)](https://travis-ci.org/zapko/CLCodable)
[![codecov](https://codecov.io/gh/zapko/CLCodable/branch/develop/graph/badge.svg)](https://codecov.io/gh/zapko/CLCodable)

## Example
```Swift
import CLCodable

struct Foo: CLDecodable {
    let bar: Int
    let baz: String


    // MARK: - CLDecodable

    init(clToken token: CLToken) throws {

        guard case .structure(let structureName, let slots) = token else {
            let message = "Expected structure root, got: '\(token)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        guard "\(type(of: self))" == structureName else {
            let message = "Expected structure of type '\(type(of: self))', got: '\(token)'"
            throw CLReadError.wrongRoot(.init(message))
        }

        guard let bar = try slots["bar"]?.int() else {
            throw CLReadError.missingValue(.init("bar"))
        }

        self.bar = bar

        guard let baz = try slots["baz"]?.string() else {
            throw CLReadError.missingValue(.init("baz"))
        }

        self.baz = baz
    }
}


func parseResponse() -> Foo? {

    let data = "#S(FOO :BAR 24 :BAZ \"Hello, World!\")"

    return try? clRead(data)
}

```

## What it already can
- Read Lisp structures and lists into Swift structures and arrays
- Print Swift structures and arrays back into Lisp structures and lists
- Transform kebab-case into camelCase and back (for straightforward cases)

## What it can't yet
- Handle package names
- Autogenerate decodable/encodable methods

## Distribution
Using Swift Package Manager

```Swift
package.dependencies.append(
    .package(url: "https://github.com/zapko/CLCodable", from: "0.8.1")
)
```

## Specs
Can be found in tests:
- [Read](https://github.com/zapko/CLCodable/blob/develop/Tests/CLCodableTests/Read_Spec.swift)
- [Print](https://github.com/zapko/CLCodable/blob/develop/Tests/CLCodableTests/Print_Spec.swift)
- [Names conversions](https://github.com/zapko/CLCodable/blob/develop/Tests/CLCodableTests/NameStyling_Spec.swift)

## Manual conformances to CLDecodable/CLEncodable
Can be found in [Samples](https://github.com/zapko/CLCodable/blob/develop/Tests/CLCodableTests/SampleStructures.swift).
The plan is to autogenerate them the same way Swift is doing it for Decodable/Encodable.
