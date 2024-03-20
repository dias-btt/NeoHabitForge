//
//  ChooseTimeView.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit

class ChooseTimeView: UIView {

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()

    var isSelected: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    var onTap: (() -> Void)?

    init(time: String, icon: UIImage?, subTitle: String) {
        super.init(frame: .zero)
        timeLabel.text = time
        iconImageView.image = icon
        subTitleLabel.text = subTitle
        print("\(time)")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        setupViews()
        setupConstraints()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(timeLabel)
        addSubview(iconImageView)
        addSubview(subTitleLabel)
        updateSelectionState()
    }

    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func updateSelectionState() {
        backgroundColor = isSelected ? UIColor(named: "SecondaryColor") : .clear
        timeLabel.textColor = isSelected ? .white : .black
        subTitleLabel.textColor = isSelected ? .white : .black
    }

    @objc private func handleTap() {
        isSelected = !isSelected
        onTap?()
    }
}

