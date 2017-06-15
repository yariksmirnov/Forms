//
//  FormFieldBehaviour.swift
//  Forms
//
//  Created by Yaroslav Smirnov on 16/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import Foundation

public final class FieldBehavior: NSObject, UITextInputTraits {
    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType  = .no
    public var spellCheckingType: UITextSpellCheckingType  = .default
    public var keyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .next
    public var enablesReturnKeyAutomatically: Bool = false
    public var isSecureTextEntry: Bool = false
    
    public var isOptional = false
    
    public static let email: FieldBehavior = {
        let email = FieldBehavior()
        email.keyboardType = .emailAddress
        return email
    }()
    
    public static let username: FieldBehavior = {
        let username = FieldBehavior()
        username.keyboardType = .namePhonePad
        return username
    }()
    
    public static let password: FieldBehavior = {
        let password = FieldBehavior()
        password.isSecureTextEntry = true
        return password
    }()
    
    public static let phone: FieldBehavior = {
        let phone = FieldBehavior()
        phone.keyboardType = .phonePad
        return phone
    }()
    
    public static let fullName: FieldBehavior = {
        let fullName = FieldBehavior()
        fullName.autocapitalizationType = .words
        return fullName
    }()
    
    public static let bio: FieldBehavior = {
        let bio = FieldBehavior()
        bio.autocorrectionType = .yes
        bio.autocapitalizationType = .sentences
        bio.isOptional = true
        return bio
    }()
}

public protocol InputTraits: UITextInputTraits {
    var autocapitalizationType: UITextAutocapitalizationType { get set }
    var autocorrectionType: UITextAutocorrectionType { get set }
    var spellCheckingType: UITextSpellCheckingType { get set }
    var keyboardType: UIKeyboardType { get set }
    var keyboardAppearance: UIKeyboardAppearance { get set }
    var returnKeyType: UIReturnKeyType { get set }
    var enablesReturnKeyAutomatically: Bool { get set }
    var isSecureTextEntry: Bool { get set }
    
}

extension InputTraits {
    func apply(behavior: FieldBehavior) {
        autocapitalizationType = behavior.autocapitalizationType
        autocorrectionType = behavior.autocorrectionType
        spellCheckingType = behavior.spellCheckingType
        keyboardType = behavior.keyboardType
        keyboardAppearance = behavior.keyboardAppearance
        returnKeyType = behavior.returnKeyType
        enablesReturnKeyAutomatically = behavior.enablesReturnKeyAutomatically
        isSecureTextEntry = behavior.isSecureTextEntry
    }
}

extension UITextField: InputTraits {}
extension UITextView: InputTraits {}
extension UISearchBar: InputTraits {}

