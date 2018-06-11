//
//  MicropubError.swift
//  Micropub
//
//  Created by Jared Sorge on 6/11/18.
//

import Foundation
import Vapor

public enum MicropubError: String, Error {
    case invalidClient
    case unknownClient
    case invalidAuthCode
    case authenticationFailed
    case UnsupportedHProperty
}

extension MicropubError: Debuggable {
    public var identifier: String {
        return rawValue
    }

    public var reason: String {
        return rawValue
    }
}
