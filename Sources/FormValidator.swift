//
//  FormValidator.swift
//  Forms
//
//  Created by Yaroslav Smirnov on 16/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import Foundation
import CoreTelephony

public enum ValidationResult {
    case valid
    case invalid(message: String)
    
    var valid: Bool {
        switch self {
        case .valid:
            return true
        default: return false
        }
    }
}

public protocol FieldValidator {
    typealias ValidatorCompletion = (ValidationResult) -> Void
    
    func validate(_ input: String,
                  mode: ValidationMode,
                  completion: @escaping ValidatorCompletion)
    
    func offlineValidation(_ input: String) -> ValidationResult
    func onlineValidation(_ input: String, completion: @escaping ValidatorCompletion)
}

public extension FieldValidator {
    
    func validate(_ input: String,
                  mode: ValidationMode,
                  completion: @escaping ValidatorCompletion)
    {
        let result = offlineValidation(input)
        
        var isOnSlowNetwork = false
        if let radio = CTTelephonyNetworkInfo().currentRadioAccessTechnology {
            isOnSlowNetwork = radio == CTRadioAccessTechnologyEdge || radio == CTRadioAccessTechnologyGPRS
        }
        
        if  mode == .online && result.valid && !isOnSlowNetwork {
            onlineValidation(input, completion: completion)
        } else {
            completion(result)
        }
    }
}

public final class EmailValidator: FieldValidator {
    
    public class func regularExpression() -> String {
        return  "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}" +
                "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
                "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
                "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
                "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
                "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
                "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    }
    
    private let regex: NSPredicate
    
    public init() {
        let exp = type(of: self).regularExpression()
        regex = NSPredicate(format: "SELF MATCHES %@", exp)
    }
    
    public func onlineValidation(_ input: String, completion: @escaping (ValidationResult) -> Void) {
        completion(.valid)
    }
    
    public func offlineValidation(_ input: String) -> ValidationResult {
        if regex.evaluate(with: input) {
            return .valid
        }
        return .invalid(message: Parameters.invalidEmailMessage)
    }
}

public final class PasswordValidator: FieldValidator {
    
    public class func regularExpression() -> String {
        return "^.{6,}$"
    }
    
    private let regexp: NSPredicate
    
    public init() {
        let exp = type(of: self).regularExpression()
        regexp = NSPredicate(format: "SELF MATCHES %@", exp)
    }
    
    public func onlineValidation(_ input: String, completion: @escaping (ValidationResult) -> Void) {
        completion(.valid)
    }
    
    public func offlineValidation(_ input: String) -> ValidationResult {
        if regexp.evaluate(with: input) {
            return .valid
        } else {
            return .invalid(message: Parameters.invalidPasswordMessage)
        }
    }
}

