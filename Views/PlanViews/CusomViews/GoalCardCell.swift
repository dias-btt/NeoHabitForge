//
//  GoalCardCell.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 12.03.2024.
//

import UIKit

class GoalCardCell: UICollectionViewCell {
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
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layer.cornerRadius = 10
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
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}
