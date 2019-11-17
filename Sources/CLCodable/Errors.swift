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

public enum CLPrintError: Error, CustomNSError {

    public struct Context {
        let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    case literalConversionFailed(Context)


    // MARK: - CustomNSError

    public static let errorDomain = "com.zababako.cl-encodable.print"

    /// The error code within the given domain.
    public var errorCode: Int {
        switch self {
        case .literalConversionFailed: return 1
        }
    }

    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        switch self {
        case .literalConversionFailed(let context):
            return [NSLocalizedDescriptionKey : "Encoding literal failed: '\(context.message)"]
        }
    }
}

