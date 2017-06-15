//
//  FormField.swift
//  Forms
//
//  Created by Yaroslav Smirnov on 16/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import UIKit

public protocol FormFieldView {
    
    var textInput: (UIResponder & InputTraits) { get }
    
    var value: String? { get set }
    
    func apply(name: String, value: String?, placeholder: String?)
    func update(for result: ValidationResult)
    
    func didStartValidation()
    func didEndValidation()
}

protocol FieldEditingDelegate {
    func didBeginEditing(field: FormField)
    func didEndEditing(field: FormField)
    func didChangeValue(field: FormField)
    func didExit(field: FormField)
}

public final class FormField {
    
    private var innerValue: String?;
    
    let validator: FieldValidator?
    let behavior: FieldBehavior
    let name: String
    let key: String
    
    var editingDelegate: FieldEditingDelegate?
    
    private(set) var valid = false
    var validated = false {
        didSet {
            if !validated {
                valid = false
            }
        }
    }
    private var validating = false
    
    var placeholder: String?
    var caption: String?
    
    var value: String? {
        return innerValue
    }
    
    var hasValue: Bool {
        return !(value?.isEmpty ?? true)
    }
    
    var isEditing: Bool {
        return view?.textInput.isFirstResponder ?? false
    }
    
    private(set) var view: FormFieldView?
    
    public init(name: String, key: String, behavior: FieldBehavior, validator: FieldValidator? = nil) {
        self.validator = validator
        self.name = name
        self.key = key
        self.behavior = behavior
    }
    
    public func attach(to view: FormFieldView) {
        view.textInput.apply(behavior: behavior)
        
        if !hasValue && behavior.isOptional {
            valid = true
            validated = true
        }
        view.apply(name: name, value: value, placeholder: placeholder)
        self.view = view
        
        if let textField = view.textInput as? UITextField {
            bindTextField(textField)
        } else if let textView = view.textInput as? UITextView {
            bindTextView(textView)
        }
    }
    
    func updateFieldView(for result: ValidationResult) {
        view?.update(for: result)
    }
    
    func didStartValidation() {
        validating = true
        view?.didStartValidation()
    }
    
    func didEndValidation() {
        validating = false
        view?.didEndValidation()
    }
    
    func validate(in mode: ValidationMode, completion: @escaping (ValidationResult) -> Void) {
        innerValue = view?.value
        validated = false
        
        view?.update(for: .valid)
        
        //Value is optional. Not interesting in value or it's existense.
        let optionalValidCase = behavior.isOptional && (validator == nil || !hasValue)
        //Value isn's optional, but no validator provider. Check if we have value and consider it valid.
        let noValidatorCase = validator == nil && hasValue
        if optionalValidCase || noValidatorCase {
            validated = true
            valid = true
            completion(.valid)
            return
        }
        //Value is required, but not filled
        if !behavior.isOptional && !hasValue {
            completion(.invalid(message: String(format: Parameters.emptyFieldMessage, name)))
        }
        //Value is not optional and validator's provided.
        //Check if we have value to valide and if it's not redundant.
        let canValidate = validator != nil && hasValue
        let needValidate = !validating
        if !canValidate || !needValidate {
            completion(.valid)
            return
        }
        //Validate value with provided validator.
        didStartValidation()
        validator?.validate(value!, mode:mode) { [weak self] result in
            self?.validated = true
            self?.valid = result.valid
            completion(result)
            self?.didEndValidation()
        }
    }
    
    //MARK: Editing Events Bindinds
    
    private func bindTextField(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(onValueChanged), for: [.editingChanged])
        textField.addTarget(self, action: #selector(onBeginEditing), for: [.editingDidBegin])
        textField.addTarget(self, action: #selector(onEndEditing), for: [.editingDidEnd])
        textField.addTarget(self, action: #selector(onExit), for: [.editingDidEndOnExit])
    }
    
    private func bindTextView(_ textView: UITextView) {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(onValueChanged), name: .UITextViewTextDidChange, object: textView)
        center.addObserver(self, selector: #selector(onBeginEditing), name: .UITextViewTextDidBeginEditing, object: textView)
        center.addObserver(self, selector: #selector(onEndEditing), name: .UITextViewTextDidEndEditing, object: textView)
    }
    
    @objc private func onValueChanged() {
        editingDelegate?.didChangeValue(field: self)
    }
    
    @objc private func onBeginEditing() {
        editingDelegate?.didBeginEditing(field: self)
    }
    
    @objc private func onEndEditing() {
        editingDelegate?.didEndEditing(field: self)
    }
    
    @objc private func onExit() {
         editingDelegate?.didExit(field: self)
    }
}
