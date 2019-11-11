//
//  Errors.swift
//  CLCodable
//
//  Created by Zapko on 2019-11-10.
//

import Foundation



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

public enum CLPrintError: Error {}

