//
//  NewsCell.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit

class NewsCell: UICollectionViewCell {
    
    static let identifier = "NewsCell"
    weak var delegate: NewsSelectionDelegate?
    var news: HabitArticleList?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Читать", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(button)

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    func configure(with model: HabitArticleList) {
        titleLabel.text = model.title
        self.news = model
        guard let url = URL(string: model.image) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self, let data = data, error == nil else {
                return
            }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } else {
            }
        }.resume()
    }

    @objc private func buttonTapped() {
        
        if let news = news {
            delegate?.didSelectNews(news)
        }
    }
}
