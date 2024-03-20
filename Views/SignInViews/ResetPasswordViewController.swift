//
//  ResetPasswordViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 19.03.2024.
//

//
//  ChangePasswordViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 14.03.2024.
//

import UIKit
import SnapKit

class ResetPasswordViewController: UIViewController {
    private var networkManager = NetworkManager()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Восстановление пароля"
        return label
    }()
    
    private let newPasswordTextField = CustomTextField(placeholder: "Новый пароль", isPassword: true)
    private let confirmNewPasswordTextField = CustomTextField(placeholder: "Подтвердите новый пароль", isPassword: true)
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сменить пароль", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        updateSaveButtonState()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .done, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(newPasswordTextField)
        view.addSubview(confirmNewPasswordTextField)
        view.addSubview(saveButton)
        newPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmNewPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        newPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmNewPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(confirmNewPasswordTextField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func updateSaveButtonState() {
        let isFilled =
        !newPasswordTextField.text!.isEmpty &&
        !confirmNewPasswordTextField.text!.isEmpty
        
        saveButton.isEnabled = isFilled
        
        if isFilled {
            saveButton.backgroundColor = UIColor(named: "SecondaryColor")
        } else {
            saveButton.backgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        }
    }
    
    @objc private func saveButtonTapped() {
        guard
              let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
              let confirmNewPassword = confirmNewPasswordTextField.text, !confirmNewPassword.isEmpty else {
            return
        }

        guard newPassword == confirmNewPassword else {
            showAlert(message: "Passwords do not match.")
            return
        }

        guard newPassword.count >= 8 else {
            showAlert(message: "New password must be at least 8 characters long.")
            return
        }

        guard newPassword.rangeOfCharacter(from: .decimalDigits) != nil else {
            showAlert(message: "New password must contain at least one digit.")
            return
        }

        guard newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]};:'\",<.>/?")) != nil else {
            showAlert(message: "New password must contain at least one special character.")
            return
        }

        networkManager.resetPassword(newPassword: newPassword, confirmPassword: confirmNewPassword) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(message: "Ваш пароль изменен.", completion: {
                        let signInVC = SignInViewController()
                        self?.navigationController?.pushViewController(signInVC, animated: true)
                    })
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error)
                }
            }
        }
    }

    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        let newPassword = newPasswordTextField.text ?? ""
        let confirmNewPassword = confirmNewPasswordTextField.text ?? ""
        
        let allFieldsFilled = !newPassword.isEmpty && !confirmNewPassword.isEmpty
        
        let passwordsMatch = newPassword == confirmNewPassword
        
        let newPasswordLengthValid = newPassword.count >= 8
        
        let containsDigit = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        
        let containsSpecialCharacter = newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]};:'\",<.>/?")) != nil
        
        let saveButtonBackgroundColor: UIColor
        
        if allFieldsFilled && passwordsMatch && newPasswordLengthValid && containsDigit && containsSpecialCharacter {
            saveButtonBackgroundColor = UIColor(named: "SecondaryColor") ?? UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        } else {
            saveButtonBackgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        }
        
        saveButton.backgroundColor = saveButtonBackgroundColor
        saveButton.isEnabled = allFieldsFilled && passwordsMatch && newPasswordLengthValid && containsDigit && containsSpecialCharacter
        
        if newPassword.isEmpty {
            newPasswordTextField.showWarning(false)
        } else {
            newPasswordTextField.showWarning(!(newPasswordLengthValid && containsDigit && containsSpecialCharacter))
        }
    }
}

