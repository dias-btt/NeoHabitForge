//
//  DayCircleView.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit

class DayCircleView: UIView {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    var day: String // Add this property

    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? UIColor(named: "SecondaryColor") : UIColor.clear
            dayLabel.textColor = isSelected ? .white : UIColor.black
        }
    }

    var onTap: (() -> Void)?

    init(day: String) {
        self.day = day // Initialize the day property
        super.init(frame: CGRect.zero)
        setupUI()
        configure(with: day)
        setupGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        self.day = "" // Initialize the day property
        super.init(coder: aDecoder)
        setupUI()
        setupGesture()
    }

    private func setupUI() {
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true

        addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configure(with day: String) {
        dayLabel.text = day
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}
