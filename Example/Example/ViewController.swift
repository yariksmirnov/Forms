//
//  ViewController.swift
//  Example
//
//  Created by Yaroslav Smirnov on 19/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import UIKit
import Forms

final class UsernameValidator: FieldValidator {
    
    func onlineValidation(_ input: String, completion: @escaping (ValidationResult) -> Void) {
        //Here supposed to be request to your backend or whatever
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
            if ["username", "qwerty", "ironman", "superhero"].contains(input) {
                completion(.invalid(message: "Username already used"))
            } else {
                completion(.valid)
            }
        }
    }
    
    func offlineValidation(_ input: String) -> ValidationResult {
        if input.count < 6 {
            return .invalid(message: "Username must be at least 6 charachters")
        }
        return .valid
    }
}

class ViewController: UIViewController {
    
    var fieldViews = [FieldView]()
    var form: Form!
    
    var formContainer = UIView()
    
    var submitButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = FormBuilder()
            .username()
            .password()
            .email()
            .name()
            .form(with: .online)
        
        form.delegate = self
        
        layoutForm()
    }
    
    override func viewDidLayoutSubviews() {
        let fieldHeight = 50
        formContainer.frame = CGRect(x: 10, y: 150, width: Int(view.bounds.width - 20), height: fieldViews.count * fieldHeight)
        for (i, view) in fieldViews.enumerated() {
            view.frame = CGRect(x: 0, y: i * fieldHeight, width: Int(formContainer.bounds.width), height: fieldHeight)
        }
        submitButton.bounds = CGRect(x: 0, y: 0, width: formContainer.bounds.width - 40, height: 50)
        submitButton.center = CGPoint(x: view.bounds.midX, y: formContainer.frame.maxY + 40)
    }
    
    func layoutForm() {
        view.addSubview(formContainer)
        view.addSubview(submitButton)
        
        fieldViews = form.formFields.map { FieldView(field: $0) }
        fieldViews.last?.textField.returnKeyType = .join
        fieldViews.forEach { self.formContainer.addSubview($0) }
        
        submitButton.layer.cornerRadius = 6
        submitButton.layer.masksToBounds = true
        
        submitButton.setTitle("Sign Up", for: .normal)
        submitButton.setBackgroundImage(UIColor.blue.image, for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        submitButton.addTarget(form, action: #selector(Form.submit), for: [.touchUpInside])
        
        view.setNeedsLayout()
    }
}

extension ViewController: FormDelegate {
    
    func didSubmitForm() {
        submitButton.isHidden = true
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.color = UIColor.blue
        spinner.sizeToFit()
        spinner.center = submitButton.center
        spinner.startAnimating()
        view.addSubview(spinner)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            spinner.removeFromSuperview()
            let label = UILabel()
            label.text = "Done!"
            label.sizeToFit()
            label.center = self.submitButton.center
            self.view.addSubview(label)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                label.removeFromSuperview()
                self.submitButton.isHidden = false
            }
        }
    }
    
    func formSumitionBecameAvailable(_ form: Form) {
        submitButton.isEnabled = true
    }
    
    func formSubmitionBecameUnavaliable(_ form: Form) {
        submitButton.isEnabled = true
    }
    
    func form(_ form: Form, didValidateWith result: ValidationResult) {
        
    }
    
}

final class FormBuilder {
    
    var fields = [FormField]()
    
    func username() -> FormBuilder {
        let username = FormField(
            name: "Username",
            key: "login",
            behavior: .username,
            validator: UsernameValidator()
        )
        fields.append(username)
        return self
    }
    
    func password() -> FormBuilder {
        let password = FormField(
            name: "Password",
            key: "password",
            behavior: .password,
            validator: PasswordValidator()
        )
        fields.append(password)
        return self
    }
    
    func email() -> FormBuilder {
        let email = FormField(
            name: "Email",
            key: "email",
            behavior: .email,
            validator: EmailValidator()
        )
        fields.append(email)
        return self
    }
    
    func name() -> FormBuilder {
        let name = FormField(
            name: "Name",
            key: "name",
            behavior: .fullName
        )
        fields.append(name)
        return self
    }
    
    func form(with mode: ValidationMode) -> Form {
        let form = Form(validationMode: mode)
        form.formFields = fields
        return form
    }
    
}

extension UIColor {
    
    var image: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        return UIGraphicsImageRenderer(bounds: rect).image { ctx in
            ctx.cgContext.setFillColor(self.cgColor)
            ctx.fill(rect)
        }
    }
    
    
}

