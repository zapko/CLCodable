# CLCodable
Codable protocol for Common Lisp structures

## Example
```Swift
import CLCodable

struct Foo: CLDecodable {
    let bar: Int
    let baz: String


    // MARK: - CLDecodable

    init(from slots: [String : CLToken]) throws {

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


func parseData() -> Foo? {

    let data = "#s(foo :bar 24 :baz \"Hello, World!\")"

    do {
        return try readStruct(clView: data) as Foo
    } catch {
        print("Error: \(error)")
        return nil
    }
}

```

## What it already can
- Read Lisp structures into Swift structures

## What it can't yet
- Handle package names
- Transform kebab-case into camelCase and back
- Encode Swift structures back into Lisp structures
- Autogenerate decodable/encodable methods

## Distribution

Library is distributed through Swift Package Manager
