import Foundation


public enum CLPrintError: Error {}

public enum CLReadError: Error, CustomNSError {

    public struct Context {
        let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    case dataCorrupted(Context)
    case emptyView
    case wrongRoot(CLToken, Context)
    case typeMismatch(Context)
    case missingValue(Context)

    public var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey : localizedDescription]
    }

    public var localizedDescription: String {
        switch self {

        case .emptyView:
            return "CLReadError.emptyView"

        case .wrongRoot(let token):
            return "CLReadError.wrongRoot: \(token)"

        case .typeMismatch(let context):
            return "CLReadError.typeMismatch: \(context.message)"

        case .dataCorrupted(let context):
            return "CLReadError.dataCorrupted: \(context.message)"
            
        case .missingValue(let context):
            return "CLReadError.missingValue: \(context.message)"
        }
    }
}

public indirect enum CLToken: Equatable {
    case cons(CLToken, CLToken)
    case number(String)
    case literal(String)
    case structure(name: String, slots: [String : CLToken])

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


struct Tokenizer {


    // MARK: - Private state

    private var iterator: String.UnicodeScalarView.Iterator
    private var cachedScalar: UnicodeScalar?


    // MARK: - Initializer
    
    init(clView: String) {
        iterator = clView.unicodeScalars.makeIterator()
    }

    mutating func nextToken() throws -> CLToken? {

        while let char = nextScalar() {

            switch char {
            case " ", "\n", "\t", "\r":
                continue

            case "#":

                switch nextScalar() {
                case "s", "S":
                    return try structToken()
                default:
                    let message = "Found '\(char)' after '#' on root level"
                    throw CLReadError.dataCorrupted(.init(message))
                }

            case "\"":
                return try literalToken()

            case "0"..."9", ",", ".", "_":
                return try numberToken(startingWith: char)

            default:
                let message = "Found '\(char)' on root level"
                throw CLReadError.dataCorrupted(.init(message))
            }
        }

        return nil
    }


    // MARK: - Private Methods

    private mutating func nextScalar() -> UnicodeScalar? {
        guard let cached = cachedScalar else {
            return iterator.next()
        }

        cachedScalar = nil
        return cached
    }

    mutating func structToken() throws -> CLToken {

        guard let firstSymbol = nextScalar(), firstSymbol == "(" else {
            let message = "Malformed struct"
            throw CLReadError.dataCorrupted(.init(message))
        }

        var nameDefined = false
        var structName = ""
        var slots: [String : CLToken] = [:]
        
        while let char = nextScalar() {
            switch (char, nameDefined) {
            case ( " ", false), 
                 ("\n", false),
                 ("\t", false),
                 ("\r", false):
                nameDefined = true

            case ( " ", true),
                 ("\n", true),
                 ("\t", true),
                 ("\r", true):
                continue

            case (_, false):
                structName.unicodeScalars.append(char)

            case (":", true):
                let fieldName = try readFieldName()

                guard slots[fieldName] == nil else {
                    let message = "Multiple values for field '\(fieldName)'"
                    throw CLReadError.dataCorrupted(.init(message))
                }

                slots[fieldName] = try nextToken()

            case (")", true):
                return .structure(name: structName, slots: slots)

            case (_, true):
                let message = "Malformed struct. Name '\(structName)'. Slots '\(slots)'. Received '\(char)'"
                throw CLReadError.dataCorrupted(.init(message))
            }
        }

        let message = "Non-terminated structure"
        throw CLReadError.dataCorrupted(.init(message))
    }

    mutating func readFieldName() throws -> String {

        var fieldName = ""

        while let char = nextScalar() {
            switch char {
            case " ": return fieldName
            default: fieldName.unicodeScalars.append(char)
            }
        }

        return fieldName
    }

    mutating func literalToken() throws -> CLToken {

        var escaped = false
        var literal = ""

        while let char = nextScalar() {
            switch (char, escaped) {
            case (_, true):
                literal.unicodeScalars.append(char)
                escaped = false

            case ("\\", false):
                escaped = true

            case ("\"", false):
                return .literal(literal)

            case (_, false):
                literal.unicodeScalars.append(char)
            }
        }

        let message = "Non-terminated string literal"
        throw CLReadError.dataCorrupted(.init(message))
    }

    mutating func numberToken(startingWith first: UnicodeScalar) throws -> CLToken {

        var token = String(first)

        while let char = nextScalar() {

            switch char {
            case "0"..."9", ",", ".", "_":
                token.unicodeScalars.append(char)

            case " ", "\t", "\n", "\r", ")":
                cachedScalar = char
                return .number(token)

            default:
                let message = "Malformed number. Contains: '\(char)'"
                throw CLReadError.dataCorrupted(.init(message))
            }
        }

        let message = "Non-terminated number '\(token)'"
        throw CLReadError.dataCorrupted(.init(message))
    }
}

public protocol CLDecodable {
    init(from slots: [String : CLToken]) throws
}

public protocol CLEncodable {
    func encode() throws -> CLToken
}

public typealias CLCodable = CLEncodable & CLDecodable


public func readStruct<T: CLDecodable>(clView: String) throws -> T {

    var tokenizer = Tokenizer(clView: clView)

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
