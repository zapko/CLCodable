//
//  Parser.swift
//  cl-codable
//
//  Created by Zapko on 2019-11-03.
//  Copyright © 2019 Zababako. All rights reserved.
//

import Foundation


enum ParsingError: Error {
    case invalidFormat(String)
}


func parse(data: String, catalog: [String : ([String : String]) -> Any]) throws -> Any {
    
    var fieldValues: [String : String] = [:]
        
    var inside: [(struct: String, field: String?)] = []
    
    var remaining = data.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
    var result: Any? = nil
    
    while !remaining.isEmpty {
     
        if remaining.lowercased().hasPrefix("#s(") {
            
            remaining = String(remaining.suffix(from: remaining.index(remaining.startIndex, offsetBy: "#s(".count)))
            
            guard let spaceIndex = remaining.firstIndex(of: " ") else {
                
                if let parenthesisIndex = remaining.firstIndex(of: ")") {
                    inside.append((String(remaining.prefix(upTo: parenthesisIndex)), nil))
                    
                    remaining = String(remaining.suffix(from: parenthesisIndex))
                    remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    continue
                }
                
                throw ParsingError.invalidFormat("Missing structure end: \(remaining)")
            }
            
            let type = String(remaining.prefix(upTo: spaceIndex))
            inside.append((type, nil))

            remaining = String(remaining.suffix(from: spaceIndex))
            remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        if remaining.hasPrefix(":") {
            
            guard let last = inside.last, last.field == nil else { throw ParsingError.invalidFormat("Field with no struct: \(remaining)")}
            
            remaining = remaining.trimmingCharacters(in: CharacterSet.init(charactersIn: ":"))
            
            guard let spaceIndex = remaining.firstIndex(of: " ") else {
                throw ParsingError.invalidFormat("Missing field name end: \(remaining)")
            }
            
            let fieldName = String(remaining.prefix(upTo: spaceIndex))
            inside[inside.count - 1].field = fieldName

            remaining = String(remaining.suffix(from: spaceIndex))
            remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        if let currentField = inside.last?.field {
            
            var value: String?
            defer {
                fieldValues[currentField] = value
                inside[inside.count - 1].field = nil
            }
            
            if remaining.hasPrefix("\"") {
                
                remaining.remove(at: remaining.startIndex)
                
                guard let endOfLiteral = remaining.firstIndex(of: "\"") else {
                    throw ParsingError.invalidFormat("Non-ending literal")
                }
                
                value = String(remaining.prefix(upTo: endOfLiteral))

                remaining = String(remaining.suffix(from: endOfLiteral))
                remaining.remove(at: remaining.startIndex)
                remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
            } else {
                
                guard let spaceIndex = remaining.firstIndex(of: " ") else {
                    
                    if let parenthesisIndex = remaining.firstIndex(of: ")") {
                        value = String(remaining.prefix(upTo: parenthesisIndex))
                        
                        remaining = String(remaining.suffix(from: parenthesisIndex))
                        remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        continue
                    }
                    
                    throw ParsingError.invalidFormat("Missing field value end: \(remaining)")
                }

                value = String(remaining.prefix(upTo: spaceIndex))

                remaining = String(remaining.suffix(from: spaceIndex))
                remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }
        
        if remaining.hasPrefix(")") {
            
            guard let (structType, field) = inside.popLast() else {
                throw ParsingError.invalidFormat("Ending struct with no start")
            }
            
            guard field == nil else {
                throw ParsingError.invalidFormat("Field with no value: \(field!) in \(structType)")
            }
            
            print("Field values: \(fieldValues)")
            result = catalog[structType]!(fieldValues)
            fieldValues = [:]
            
            remaining.remove(at: remaining.startIndex)
            remaining = remaining.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        print(remaining)
        // TODO: protect from infinite loop
    }
    
    guard let result2 = result else {
        throw ParsingError.invalidFormat("There is no object")
    }
    
    return result2
}
