//
//  CustomTextField.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 04.03.2024.
//
import UIKit
import SnapKit

class CustomTextField: UITextField {
    
    private var isPasswordHidden = true
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SecondaryColor")
        return view
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Password must be at least 8 characters long"
        label.isHidden = true
        return label
    }()
    
    private lazy var hideUnhideButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(hideUnhideButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override var text: String? {
        didSet {
            isSecureTextEntry = isPasswordHidden
        }
    }
    
    init(placeholder: String = "", isPassword: Bool = false) {
        super.init(frame: .zero)
        setupTextField(placeholder: placeholder)
        setupBottomLine()
        if isPassword {
            setupHideUnhideButton()
        } else{
            isPasswordHidden = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField(placeholder: String) {
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ])
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func setupBottomLine() {
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func setupWarningLabel() {
        addSubview(warningLabel)
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomLine.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    private func setupHideUnhideButton() {
        addSubview(hideUnhideButton)
        hideUnhideButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func hideUnhideButtonTapped() {
        isPasswordHidden.toggle()
        let imageName = isPasswordHidden ? "eye" : "eye.fill"
        hideUnhideButton.setImage(UIImage(systemName: imageName), for: .normal)
        isSecureTextEntry = isPasswordHidden
    }
    
    @objc private func textDidChange() {
        isSecureTextEntry = isPasswordHidden
    }
    
    func showWarning(_ show: Bool) {
        // You can implement your own warning mechanism, such as changing text color or showing/hiding an icon.
        // For example, you can change the border color of the text field.
        bottomLine.backgroundColor = show ? UIColor.red : UIColor(named: "SecondaryColor")
        warningLabel.isHidden = !show
    }
}
