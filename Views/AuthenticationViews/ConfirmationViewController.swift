//
//  ConfirmationViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 06.03.2024.
//

import UIKit
import SnapKit
import VKPinCodeView

class ConfirmationViewController: UIViewController {
    
    var networkManager = NetworkManager()
    var isFromForgotPassword: Bool?
        
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "На ваш номер телефона отправлен код введите его ниже"
        label.numberOfLines = 0
        return label
    }()

    var pinView: VKPinCodeView = {
        let pinView = VKPinCodeView()
        pinView.translatesAutoresizingMaskIntoConstraints = false
        pinView.onSettingStyle = { BorderStyle(cornerRadius: 10, borderColor: UIColor(named: "SecondaryColor") ?? .green) }
        pinView.becomeFirstResponder()
        return pinView
    }()
    
    var resendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отправить код", for: .normal)
        button.setTitleColor(UIColor(named: "ThirdColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "ThirdColor")
        return label
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()

    var countdownTimer: Timer?
    var countdownSeconds = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        startCountdown()
        title = "OTP"
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .done, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        pinView.onComplete = {code, pinView in
            if code != "5439" {
                pinView.isError = true
                print("Error in code")
            } else{
                guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                    return
                }
                self.generateTokens(enteredOTP: code, userId: Int(userId) ?? -1)
            }
        }
        pinView.validator = validator(_:)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI(){
        view.addSubview(subTitleLabel)
        view.addSubview(pinView)
        view.addSubview(resendButton)
        view.addSubview(countdownLabel)
        view.addSubview(signInButton)
    }
    
    private func setupConstraints(){
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        pinView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-60)
            make.height.equalTo(40)
            make.width.equalTo(pinView.intrinsicContentSize.width)
        }
        
        countdownLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pinView.snp.bottom).offset(20)
        }
        
        resendButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pinView.snp.bottom).offset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(resendButton.snp.bottom).offset(180)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func validator(_ code: String) -> Bool {
        return !code.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).isEmpty
    }
    
    @objc private func signInButtonTapped() {
        navigateToNextScreen()
    }
    
    private func generateTokens(enteredOTP: String, userId: Int) {
        networkManager.verifyOTP(userId: userId, code: enteredOTP) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tokenResponse):
                    let accessToken = tokenResponse.access
                    let refreshToken = tokenResponse.refresh
                    
                    UserDefaults.standard.set(accessToken, forKey: "AccessToken")
                    UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self.navigateToNextScreen()
                    
                case .failure(let error):
                    print("Error verifying OTP: \(error)")
                    self.showAlert(message: "Failed to verify OTP. Please try again.")
                }
            }
        }
    }

    private func navigateToNextScreen() {
        if isFromForgotPassword ?? false{
            let resetPasswordViewController = ResetPasswordViewController()
            self.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(resetPasswordViewController, animated: true)
        } else {
            let homeViewController = TabBarViewController()
            self.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(homeViewController, animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Confirmation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func startCountdown() {
        countdownLabel.isHidden = false
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.countdownSeconds > 0 {
                self.countdownSeconds -= 1
                self.countdownLabel.text = "Отправить код через \(self.countdownSeconds) секунд"
            } else {
                timer.invalidate()
                self.countdownLabel.isHidden = true
                self.resendButton.isHidden = false
                self.resendButton.isEnabled = true
            }
        }
    }

    @objc private func resendButtonTapped() {
        countdownSeconds = 30
        startCountdown()
        resendButton.isEnabled = false
        resendButton.isHidden = true
    }
}


