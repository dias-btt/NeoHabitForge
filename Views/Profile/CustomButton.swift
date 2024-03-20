//
//  CustomButton.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 14.03.2024.
//

import UIKit
import SnapKit

class CustomButton: UIButton {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: "SecondaryColor")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SecondaryColor")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(icon: UIImage?, name: String) {
        super.init(frame: .zero)
        
        iconImageView.image = icon
        nameLabel.text = name
        
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(lineView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24) // Adjust size as needed
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalTo(iconImageView)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
