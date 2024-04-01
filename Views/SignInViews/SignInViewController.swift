//
//  AuthenticationViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 01.03.2024.
//
import UIKit
import SnapKit
import PhoneNumberKit

class SignInViewController: UIViewController {
    
    var networkManager = NetworkManager()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Вход в аккаунт"
        return label
    }()
    
    private let passwordTextField = CustomTextField(placeholder: "Введите пароль", isPassword: true)
    private let phoneNumberTextField: PhoneNumberTextField = {
        let phone = PhoneNumberTextField()
        phone.withFlag = true
        phone.withPrefix = true
        phone.withExamplePlaceholder = true
        return phone
    }()
    
    private let rememberMeCheckboxButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkbox_unchecked"), for: .normal)
        button.setImage(UIImage(named: "checkbox_checked"), for: .selected)
        button.addTarget(self, action: #selector(rememberMeCheckboxTapped), for: .touchUpInside)
        return button
    }()
    
    private let rememberMeKey = "RememberMeState"
        
    private let rememberMeLabel: UILabel = {
        let label = UILabel()
        label.text = "Запомнить меня"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Забыли пароль?", for: .normal)
        button.setTitleColor(UIColor(named: "SecondaryColor"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "У вас нет аккаунта?"
        return label
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать аккаунт", for: .normal)
        button.setTitleColor(UIColor(named: "SecondaryColor"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupTextFieldTargets()
        loadRememberMeState()
        navigationItem.hidesBackButton = true
    }
        
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(phoneNumberTextField)
        view.addSubview(passwordTextField)
        view.addSubview(rememberMeCheckboxButton)
        view.addSubview(rememberMeLabel)
        view.addSubview(signInButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(subTitleLabel)
        view.addSubview(registerButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(40)
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
        
        rememberMeCheckboxButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
        }
        rememberMeLabel.snp.makeConstraints { make in
            make.leading.equalTo(rememberMeCheckboxButton.snp.trailing).offset(10)
            make.centerY.equalTo(rememberMeCheckboxButton)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(200)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Button Actions
    @objc private func signInButtonTapped() {
        guard let phone = phoneNumberTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }

        networkManager.loginUser(phone: phone, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    let accessToken = response.access
                    let refreshToken = response.refresh
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(accessToken, forKey: "AccessToken")
                    UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
                    self.navigateToHomeViewController()
                case .failure(let error):
                    self.showAlert(withMessage: "Неправильный пароль или Аккаунт не существует")
                }
            }
        }
    }

    private func loadRememberMeState() {
        let rememberMeState = UserDefaults.standard.bool(forKey: rememberMeKey)
        rememberMeCheckboxButton.isSelected = rememberMeState
    }
        
    @objc private func rememberMeCheckboxTapped() {
        rememberMeCheckboxButton.isSelected.toggle()
        UserDefaults.standard.set(rememberMeCheckboxButton.isSelected, forKey: rememberMeKey)
    }
    
    private func navigateToHomeViewController() {
        let homeViewController = TabBarViewController()
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    @objc private func forgotPasswordButtonTapped() {
        let forgotPasswordViewController = ForgotPasswordViewController()
        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    @objc private func registerButtonTapped() {
        let registerViewController = AuthenticationViewController()
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    // MARK: - TextField Actions
    
    private func setupTextFieldTargets() {
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let phoneNumber = phoneNumberTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let isPasswordValid = password.count >= 8
        
        signInButton.isEnabled = !phoneNumber.isEmpty && isPasswordValid
        signInButton.backgroundColor = signInButton.isEnabled ? UIColor(named: "SecondaryColor") : UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        
        if password.isEmpty {
            passwordTextField.showWarning(false)
        } else {
            passwordTextField.showWarning(!isPasswordValid)
        }
    }
    
    private func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
