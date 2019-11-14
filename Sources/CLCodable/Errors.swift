//
//  Errors.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-10.
//

import Foundation



public enum CLReadError: Error {

    public struct Context {
        let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    case dataCorrupted(Context)
    case emptyView
    case wrongRoot(Context)
    case typeMismatch(Context)
    case missingValue(Context)
    case literalConversionFailed(Context)
}

public enum CLPrintError: Error {

    public struct Context {
        let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    case literalConversionFailed(Context)
}

