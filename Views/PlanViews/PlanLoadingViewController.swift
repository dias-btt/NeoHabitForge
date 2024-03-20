//
//  PlanLoadingViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 29.02.2024.
//

import UIKit
import SnapKit

class PlanLoadingViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Создаем ваш план привычек"
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Помни свои цели, оставайся на пути и вперед, к новым вершинам!"
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        label.textColor = UIColor(named: "SecondaryColor")
        label.text = "0%"
        return label
    }()
    
    private let circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(named: "SecondaryColor")?.cgColor
        layer.lineWidth = 15
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        animateCircleStrokeAndPercentage(duration: 4)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }
        
        view.addSubview(percentageLabel)
        percentageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let radius: CGFloat = 100
        let centerPoint = view.center
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        circleLayer.path = circlePath.cgPath
        view.layer.addSublayer(circleLayer)
        
        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(percentageLabel.snp.bottom).offset(150)
        }
    }

    
    private func animateCircleStrokeAndPercentage(duration: TimeInterval) {
        var percentage = 0
        Timer.scheduledTimer(withTimeInterval: duration / 100, repeats: true) { timer in
            guard percentage < 100 else {
                timer.invalidate()
                // Navigate to RegistrationViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigateToRegistration()
                }
                return
            }
            percentage += 1
            let currentPercentage = "\(percentage)%"
            self.percentageLabel.text = currentPercentage
        }
        
        let circleAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circleAnimation.duration = duration
        circleAnimation.fromValue = 0
        circleAnimation.toValue = 1
        circleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        circleLayer.add(circleAnimation, forKey: "circleAnimation")
    }
    
    private func navigateToRegistration() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        let registrationViewController = AuthenticationViewController()
        navigationController?.pushViewController(registrationViewController, animated: true)
    }
}

