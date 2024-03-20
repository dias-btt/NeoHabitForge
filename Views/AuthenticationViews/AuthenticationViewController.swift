//
//  AuthenticationViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 01.03.2024.
//
import UIKit
import SnapKit
import PhoneNumberKit

class AuthenticationViewController: UIViewController {
    
    var networkManager = NetworkManager()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = "Регистрация"
        return label
    }()
    
    private let nameTextField = CustomTextField(placeholder: "Имя")
    private let passwordTextField = CustomTextField(placeholder: "Придумайте пароль", isPassword: true)
    private let phoneNumberTextField: PhoneNumberTextField = {
        let phone = PhoneNumberTextField()
        phone.withFlag = true
        phone.withPrefix = true
        phone.withExamplePlaceholder = true
        return phone
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "Уже есть аккаунт?"
        return label
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor(named: "SecondaryColor"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupTextFieldTargets()
        
        navigationItem.hidesBackButton = true
    }
        
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(phoneNumberTextField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
        view.addSubview(subTitleLabel)
        view.addSubview(signInButton)
        passwordTextField.setupWarningLabel()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        let greenLineView = UIView()
        greenLineView.backgroundColor = UIColor(named: "SecondaryColor")
        view.addSubview(greenLineView)
        greenLineView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(4)
            make.leading.trailing.equalTo(phoneNumberTextField)
            make.height.equalTo(1)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(200)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Button Actions
    @objc private func registerButtonTapped() {
        guard let firstName = nameTextField.text,
                let phone = phoneNumberTextField.text,
                let password = passwordTextField.text else {
            return
        }
        
        networkManager.registerUser(firstName: firstName, phone: phone, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    let userId = response.message.id
                    UserDefaults.standard.set(userId, forKey: "userId")
                    print("User registered successfully with ID: \(userId)")
                    self.navigateToConfirmationViewController()
                case .failure(let error):
                    print("Error registering user: \(error)")
                    self.handleRegistrationError(error)
                }
            }
        }
    }
    
    private func navigateToConfirmationViewController() {
        let confirmationViewController = ConfirmationViewController()
        navigationController?.pushViewController(confirmationViewController, animated: true)
    }
    
    private func handleRegistrationError(_ error: Error) {
            if let decodingError = error as? DecodingError,
               case .keyNotFound(let key, _) = decodingError,
               key.stringValue == "error" {
                showAlert(message: "User with this phone number already exists.")
            } else {
                showAlert(message: "An error occurred while registering user.")
            }
        }
        
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Registration Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    @objc private func signInButtonTapped() {
        // Handle create account button tap
        // Navigate to the registration screen
        let signInViewController = SignInViewController()
        navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    // MARK: - TextField Actions
    
    private func setupTextFieldTargets() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let name = nameTextField.text ?? ""
        let phoneNumber = phoneNumberTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        // Password must be at least 8 characters long
        let isPasswordValid = password.count >= 8
        
        // Password must contain at least one special character
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:,.<>?")
        let containsSpecialCharacter = password.rangeOfCharacter(from: specialCharacterSet) != nil
        
        // Password must contain at least one digit
        let digitCharacterSet = CharacterSet.decimalDigits
        let containsDigit = password.rangeOfCharacter(from: digitCharacterSet) != nil
        
        let uppercaseCharacterSet = CharacterSet.uppercaseLetters
        let containsUppercase = password.rangeOfCharacter(from: uppercaseCharacterSet) != nil
        
        let isPasswordRequirementsMet = isPasswordValid && containsSpecialCharacter && containsDigit && containsUppercase
        
        registerButton.isEnabled = !name.isEmpty && !phoneNumber.isEmpty && isPasswordRequirementsMet
        registerButton.backgroundColor = registerButton.isEnabled ? UIColor(named: "SecondaryColor") : UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        
        if password.isEmpty {
            passwordTextField.showWarning(false)
        } else {
            passwordTextField.showWarning(!isPasswordRequirementsMet)
        }
    }
}

