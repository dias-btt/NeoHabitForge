//
//  DaySelectionView.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//
import UIKit
import SnapKit

protocol SectionViewDelegate: AnyObject {
    func toggleSwitchValueChanged(isOn: Bool)
}

class SectionView: UIView {
    weak var delegate: SectionViewDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white 
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "arrow_right"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    private let colorView: UIView = {
        let color = UIView()
        color.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        color.layer.cornerRadius = 5
        color.isHidden = true
        return color
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.isOn = false
        toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged(_:)), for: .valueChanged)
        toggleSwitch.isHidden = true
        return toggleSwitch
    }()

    init(title: String, subtitle: String?, target: Any?, action: Selector, notify: Bool = false) {
        super.init(frame: .zero)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.addTarget(target, action: action, for: .touchUpInside)
        setupViews()
        setupConstraints()
        if notify{
            allowToggleSwitch()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(titleLabel)
        actionButton.addSubview(subtitleLabel)
        actionButton.addSubview(arrowImageView)
        actionButton.addSubview(daysLabel)
        actionButton.addSubview(colorView)
        actionButton.addSubview(toggleSwitch)
        addSubview(actionButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }

        actionButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(66)
        }

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        daysLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowImageView.snp.leading).inset(-4)
            make.centerY.equalToSuperview()
        }
        
        colorView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func actionButtonTapped() {
        // Perform action when the section view is tapped
        // You can open a small screen or perform any other action
    }
    
    @objc private func toggleSwitchValueChanged(_ sender: UISwitch) {
        let isToggled = sender.isOn
        delegate?.toggleSwitchValueChanged(isOn: isToggled)
    }
    
    func update(with string: String){
        daysLabel.isHidden = false
        daysLabel.text = string
    }
    
    func update(with image: Icon){
        if let iconURL = URL(string: image.image) {
            arrowImageView.sd_setImage(with: iconURL, placeholderImage: nil, options: [], completed: nil)
        }
    }
    
    func update(with color: Color){
        arrowImageView.isHidden = true
        colorView.isHidden = false
        colorView.backgroundColor = UIColor(hexString: color.name)
    }
    
    func allowToggleSwitch(){
        arrowImageView.isHidden = true
        toggleSwitch.isHidden = false
    }
}


