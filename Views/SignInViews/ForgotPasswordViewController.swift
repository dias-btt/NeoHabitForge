//
//  ForgotPasswordViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 14.03.2024.
//

import UIKit
import SnapKit
import PhoneNumberKit

class ForgotPasswordViewController: UIViewController {
    
    private let phoneNumberTextField: PhoneNumberTextField = {
        let phone = PhoneNumberTextField()
        phone.withFlag = true
        phone.withPrefix = true
        phone.withExamplePlaceholder = true
        return phone
    }()
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let greenLineView = UIView()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .done, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        title = "Введите свой номер"
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func phoneNumberTextFieldDidChange(_ textField: UITextField) {
        let phoneNumberKit = PhoneNumberKit()
        do {
            _ = try phoneNumberKit.parse(textField.text ?? "")
            errorLabel.isHidden = true
            greenLineView.backgroundColor = UIColor(named: "SecondaryColor")
            signInButton.isEnabled = true
        } catch {
            errorLabel.isHidden = false
            errorLabel.text = "Неправильный формат номера"
            greenLineView.backgroundColor = .red
            signInButton.isEnabled = false
        }
    }
    
    private func setupUI() {
        view.addSubview(phoneNumberTextField)
        view.addSubview(signInButton)
        view.addSubview(errorLabel)
    }
    
    private func setupConstraints() {
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        greenLineView.backgroundColor = UIColor(named: "SecondaryColor")
        view.addSubview(greenLineView)
        greenLineView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(4)
            make.leading.trailing.equalTo(phoneNumberTextField)
            make.height.equalTo(1)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(greenLineView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(phoneNumberTextField)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    @objc private func signInButtonTapped() {
        let confirmationViewController = ConfirmationViewController()
        confirmationViewController.isFromForgotPassword = true
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }
}

