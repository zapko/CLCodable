import Foundation


public enum ParsingError: Error, CustomNSError {
    case invalidFormat(String)
    case internalError(context: [String: Any])
    case invalidLiteral(String)
    case missingValue(field: String)
    case unreadableValue(field: String, value: String, type: Any.Type)
    
    public var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey : localizedDescription]
    }

    public var localizedDescription: String {
        switch self {
            
        case .invalidFormat(let message):
            return "invalid format " + message
        case .internalError(let context):
            return "internal error " + context.description
        case .invalidLiteral(let literal):
            return "invalid literal " + literal
        case .missingValue(let field):
            return "missing value " + field
        case .unreadableValue(let field, let value, let type):
            return ["unreadable value", field, value, "\(type)"].joined(separator: " ")
        }
    }
}

let spaces = CharacterSet.whitespacesAndNewlines
let structPrefix = "#s("
let listPrefix = "'("

public protocol InitiableWithStringsDictionary {
    init(dictionary: [String: String]) throws
}

public func read<T: InitiableWithStringsDictionary>(clView: String) throws -> T {
    
    var fieldValues: [String : String] = [:]
        
    var inside: (struct: String, field: String?)? = nil
    
    var remaining = clView.trimmingCharacters(in: spaces)

    var result: T? = nil

    var previousLength = remaining.count
    while !remaining.isEmpty {

        // Starting struct context
        if remaining.prefix(structPrefix.count).lowercased() == structPrefix  {
            
            remaining = String(remaining.suffix(
                from: remaining.index(remaining.startIndex, offsetBy: structPrefix.count))
            )

            guard let spaceIndex = remaining.rangeOfCharacter(from: spaces)?.lowerBound else {
                
                if let parenthesisIndex = remaining.firstIndex(of: ")") {
                    inside = (String(remaining.prefix(upTo: parenthesisIndex)), nil)
                    
                    remaining = String(remaining.suffix(from: parenthesisIndex))
                    remaining = remaining.trimmingCharacters(in: spaces)
                    continue
                }
                
                throw ParsingError.invalidFormat("Missing structure end: \(remaining)")
            }
            
            let type = String(remaining.prefix(upTo: spaceIndex))
            inside = (type, nil)

            remaining = String(remaining.suffix(from: spaceIndex))
            remaining = remaining.trimmingCharacters(in: spaces)
        }

        // Starting property name context
        if remaining.hasPrefix(":") {
            
            guard let last = inside, last.field == nil else {
                throw ParsingError.invalidFormat("Field with no struct: \(remaining)")
            }
            
            remaining = remaining.trimmingCharacters(in: CharacterSet.init(charactersIn: ":"))
            
            guard let spaceIndex = remaining.rangeOfCharacter(from: spaces)?.lowerBound else {
                throw ParsingError.invalidFormat("Missing field name end: \(remaining)")
            }
            
            let fieldName = String(remaining.prefix(upTo: spaceIndex))
            inside!.field = fieldName

            remaining = String(remaining.suffix(from: spaceIndex))
            remaining = remaining.trimmingCharacters(in: spaces)
        }

        // Starting property value context
        if let currentField = inside?.field {
            
            var value: String?
            defer {
                fieldValues[currentField] = value
                inside!.field = nil
            }
            
            if remaining.hasPrefix("\"") {
                
                remaining.remove(at: remaining.startIndex)
                
                guard let endOfLiteral = remaining.closingQuoteIndex() else {
                    throw ParsingError.invalidFormat("Non-ending literal")
                }
                
                value = try String(remaining.prefix(upTo: endOfLiteral)).unscreenedLiteral()

                remaining = String(remaining.suffix(from: endOfLiteral))
                remaining.remove(at: remaining.startIndex)
                remaining = remaining.trimmingCharacters(in: spaces)
                
            } else if remaining.hasPrefix(structPrefix) {
                
                guard let endOfStruct = remaining.closingParanthesisIndex() else {
                    throw ParsingError.invalidFormat("Non-ending nested struct")
                }
                
                value = String(remaining.prefix(through: endOfStruct))

                remaining = String(remaining.suffix(from: remaining.index(after: endOfStruct)))
                remaining = remaining.trimmingCharacters(in: spaces)

            } else {
                
                guard let spaceIndex = remaining.rangeOfCharacter(from: spaces)?.lowerBound else {
                    
                    if let parenthesisIndex = remaining.firstIndex(of: ")") {
                        value = String(remaining.prefix(upTo: parenthesisIndex))
                        
                        remaining = String(remaining.suffix(from: parenthesisIndex))
                        remaining = remaining.trimmingCharacters(in: spaces)
                        continue
                    }
                    
                    throw ParsingError.invalidFormat("Missing field value end: \(remaining)")
                }

                value = String(remaining.prefix(upTo: spaceIndex))

                remaining = String(remaining.suffix(from: spaceIndex))
                remaining = remaining.trimmingCharacters(in: spaces)
            }
        }

        // Closing struct context
        if remaining.hasPrefix(")") {
            
            guard let (structType, field) = inside else {
                throw ParsingError.invalidFormat("Ending struct with no start")
            }
            
            guard field == nil else {
                let message = "Field with no value: \(field!) in \(structType)"
                throw ParsingError.invalidFormat(message)
            }
            
            print("Field values: \(fieldValues)")
            result = try T(dictionary: fieldValues)
            fieldValues = [:]
            
            remaining.remove(at: remaining.startIndex)
            remaining = remaining.trimmingCharacters(in: spaces)
        }

        print(remaining)

        // Protecting from infinite loops
        if previousLength <= remaining.count {
            throw ParsingError.internalError(context: [
                "values"    : fieldValues,
                "struct"    : String(describing: inside),
                "remaining" : remaining
            ])
        }
        previousLength = remaining.count
    }
    
    guard let result2 = result else {
        throw ParsingError.invalidFormat("There is no object")
    }
    
    return result2
}


extension String {

    func closingQuoteIndex() -> String.Index? {

        var screened = false
        return firstIndex {

            switch ($0, screened) {
            case ("\\", true):  screened = false
            case ("\\", false): screened = true
            case ("\"", true):  screened = false
            case ("\"", false): return true
            default:            screened = false
            }

            return false
        }
    }
    
    func closingParanthesisIndex() -> String.Index? {
        
        var counter = 0
        return firstIndex {
            
            switch $0 {
            case "(": counter += 1
            case ")": counter -= 1
                      if counter == 0 { return true }
            default: break
            }
            
            return false
        }
    }

    func unscreenedLiteral() throws -> String {

        typealias Aggregator = (chars: [Character], screenOn: Bool)

        let aggregator = try self.reduce(into: Aggregator(chars: [], screenOn: false)) {
            (aggregator, char) in

            switch (char, aggregator.screenOn) {
            case ("\\", true):
                aggregator.chars.append(char)
                aggregator.screenOn = false

            case ("\\", false):
                aggregator.screenOn = true

            case ("\"", true):
                aggregator.chars.append(char)
                aggregator.screenOn = false

            case ("\"", false):
                throw ParsingError.invalidLiteral("Unscreened quote in: '\(self)'")

            case (_, true):
                throw ParsingError.invalidLiteral("Screened non-quote in: '\(self)'")

            case (_, false):
                aggregator.chars.append(char)
            }
        }

        return String(aggregator.chars)
    }
}