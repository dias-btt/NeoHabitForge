//
//  CongratulationsViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 15.03.2024.
//

import Foundation
import UIKit
import SnapKit

class CongratulationsViewController: UIViewController {
    weak var navigationControllerRef: UINavigationController?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "congrats")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "Поздравляем!"
        return label
    }()
    
    private let congratsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "Цель достигнута!"
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Сегодня вы выполнили цель запланированной привычки"
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Продолжить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var dismissAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        view.backgroundColor = .white
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(congratsLabel)
        view.addSubview(textLabel)
        view.addSubview(continueButton)
    }
    
    private func setupConstraints(){
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(240)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        congratsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
        }
        
        textLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(congratsLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
    }

    
    @objc func continueButtonTapped() {
        dismiss(animated: true) {
            let habitInfoVC = HabitInfoViewController()
            self.navigationControllerRef?.pushViewController(habitInfoVC, animated: true)
        }
    }
}
