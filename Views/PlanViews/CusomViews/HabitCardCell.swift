//
//  HabitViewCell.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 12.03.2024.
//

import UIKit

class HabitCardCell: UICollectionViewCell {
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowRadius = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
        
    
    private func setupViews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(10)
        }
    }
}


