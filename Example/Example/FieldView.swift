//
//  FieldView.swift
//  Example
//
//  Created by Yaroslav Smirnov on 21/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import Foundation
import Forms

final class FieldView: UIView, FormFieldView {
    
    let textField = UITextField()
    let underline = UIView()
    let warningLabel = UILabel()
    let nameLabel = UILabel()
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var textInput: (UIResponder & InputTraits) {
        return textField
    }
    
    var value: String? {
        set {
            textField.text = newValue
        } get {
            return textField.text
        }
    }
    
    convenience init(field: FormField) {
        self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        field.attach(to: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textField)
        addSubview(underline)
        addSubview(warningLabel)
        addSubview(nameLabel)
        addSubview(indicator)
        
        indicator.hidesWhenStopped = true
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        nameLabel.textAlignment = .right
        
        warningLabel.textColor = .red
        warningLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        
        update(for: .valid)
    }
    
    override func layoutSubviews() {
        textField.frame = CGRect(x: 80, y: 0, width: bounds.width, height: 34)
        nameLabel.frame = CGRect(x: 0, y: 0, width: 70, height: 34)
        underline.frame = CGRect(x: 80, y: bounds.height - 20, width: bounds.width - 80, height: 2)
        warningLabel.frame = CGRect(x: 80, y: bounds.height - 20, width: bounds.width - 80, height: 20)
        indicator.sizeToFit()
        indicator.center = CGPoint(x: bounds.width - 20, y: 15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func apply(name: String, value: String?, placeholder: String?) {
        nameLabel.text = name
        textField.text = value
        textField.placeholder = placeholder
    }
    
    func didStartValidation() {
        indicator.startAnimating()
    }
    
    func didEndValidation() {
        indicator.stopAnimating()
    }
    
    func update(for result: ValidationResult) {
        switch result {
        case .valid:
            textField.textColor = .black
            underline.backgroundColor = .blue
            warningLabel.isHidden = true
        case .invalid(let message):
            textField.textColor = .red
            underline.backgroundColor = .red
            warningLabel.text = message
            warningLabel.isHidden = false
        }
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }
}
