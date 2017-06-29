//
//  Form.swift
//  Forms
//
//  Created by Yaroslav Smirnov on 15/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import Foundation

public enum ValidationMode {
    case online
    case offline
}

public protocol FormDelegate: class {
    
    func didSubmitForm()
    
    func formSumitionBecameAvailable(_ form: Form)
    func formSubmitionBecameUnavaliable(_ form: Form)
    
    func form(_ form: Form, didValidateWith result: ValidationResult)
}

public final class Form {
    
    let validationMode: ValidationMode
    
    public weak var delegate: FormDelegate?
    
    public init(validationMode: ValidationMode) {
        self.validationMode = validationMode
    }
    
    public var formFields = [FormField]() {
        didSet {
            oldValue.forEach { $0.editingDelegate = nil }
            mapKeyToFields.removeAll()
            formFields.forEach {
                $0.editingDelegate = self
                mapKeyToFields[$0.key] = $0
            }
            notifyAboutFormValidityChanges()
        }
    }
    private(set) var mapKeyToFields = [String: FormField]()
    
    var allowTimeoutValidation = true
    
    public var isValid: Bool {
        return formFields.reduce(true) { $0 && $1.valid }
    }
    
    public var isEditing: Bool {
        return formFields.reduce(false) { $0 || $1.isEditing }
    }
    
    public var json: [String: String] {
        var result = [String: String]()
        formFields.forEach { result[$0.name] = $0.value }
        return result
    }
    
    public func formField(forName name: String) -> FormField? {
        return mapKeyToFields[name]
    }
    
    @objc public func submit() {
        validate()
        if isValid {
            self.delegate?.didSubmitForm()
        }
    }
    
    private let performFunction = PerformFunction()
    private func validate(_ field: FormField) {
        let mode = field.isEditing ? .offline : validationMode
        field.validate(in: mode) { [weak self] result in
            guard let s = self else { return }
            s.notifyAboutFormValidityChanges()
            if s.allowTimeoutValidation {
                s.performFunction.cancel()
                if field.isEditing {
                    s.performFunction.afterDelay(4) {
                        field.updateFieldView(for: result)
                    }
                    if field === s.formFields.last {
                        s.performFunction.afterDelay(8) {
                            s.notifyFormDidValidate(with: result)
                        }
                    }
                }
            }
            if !field.isEditing {
                field.updateFieldView(for: result)
                s.notifyFormDidValidate(with: result)
            }
        }
    }
    
    func validate() {
        formFields.forEach { field in
            field.validate(in: .offline) { result in
                field.updateFieldView(for: result)
            }
        }
        notifyAboutFormValidityChanges()
    }
    
    public func updateFormFields(with results: [String: ValidationResult]) {
        for (key, value) in results {
            let field = mapKeyToFields[key]
            field?.updateFieldView(for: value)
        }
    }
    
    private func notifyFormDidValidate(with result: ValidationResult) {
        delegate?.form(self, didValidateWith: result)
    }
    
    private func notifyAboutFormValidityChanges() {
        if isValid {
            delegate?.formSumitionBecameAvailable(self)
        } else {
            delegate?.formSubmitionBecameUnavaliable(self)
        }
    }
}

extension Form: FieldEditingDelegate {
    
    func didChangeValue(field: FormField) {
        validate(field)
    }
    
    func didBeginEditing(field: FormField) {}
    
    func didEndEditing(field: FormField) {
        validate(field)
    }
    
    func didExit(field: FormField) {
        if field === formFields.last {
            submit()
        } else {
            guard let idx = formFields.index(where: { $0 === field }) else { return }
            let nextIdx = idx + 1
            if nextIdx < formFields.count {
                formFields[nextIdx].view?.textInput.becomeFirstResponder()
            }
        }
    }
}

typealias Function = () -> Void

final class PerformFunction: NSObject {
    
    final class Trumpoline: NSObject {
        var function: Function
        
        init(_ function: @escaping Function) {
            self.function = function
        }
    }
    
    func afterDelay(_ delay: TimeInterval, function: @escaping Function) {
        let trumpoline = Trumpoline(function)
        perform(#selector(selectorWrapper(_:)), with: trumpoline, afterDelay: delay)
    }
    
    func cancel() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    @objc func selectorWrapper(_ trumpoline: Trumpoline) {
        trumpoline.function()
    }
}
