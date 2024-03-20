//
//  PhoneTextField.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 04.03.2024.
//
import UIKit
import PhoneNumberKit
import SnapKit

class PhoneTextField: UITextField {
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SecondaryColor") // Change color as needed
        return view
    }()
    
    private let phoneNumberKit = PhoneNumberKit()
    
    override var placeholder: String? {
        didSet {
            if let placeholder = placeholder {
                attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                    .foregroundColor: UIColor.lightGray
                ])
            }
        }
    }
    
    init(placeholder: String? = nil) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        setupBottomLine()
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBottomLine() {
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(6)
        }
    }
    
    @objc private func textDidChange() {
        formatPhoneNumber()
    }
    
    private func formatPhoneNumber() {
        guard var newText = text else { return }
        do {
            let phoneNumber = try phoneNumberKit.parse(newText)
            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .international, withPrefix: true)
            newText = formattedNumber
        } catch {
            print("Invalid phone number format: \(newText)")
        }
        super.text = newText
    }
}

