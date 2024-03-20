//
//  HabitInfoViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit
import FSCalendar

class HabitInfoViewController: UIViewController {

    var habit: HabitCreateResponse?
    var completedDates: [Date] = [Date()]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let goalTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let goalToday: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let streak: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        return label
    }()

    private let endTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let todayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let weekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var changeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.customView = createChangeButtonView()
        return button
    }()
    
    private lazy var firstRectangleStackView: UIStackView = {
        let stackView = createLabelStackView()
        stackView.backgroundColor = UIColor(named: "SecondaryColor")
        return stackView
    }()

    private lazy var secondRectangleStackView: UIStackView = {
        let stackView = createLabelStackView()
        stackView.backgroundColor = .red
        return stackView
    }()
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.scope = .month
        calendar.locale = Locale(identifier: "ru_RU")
        
        calendar.appearance.headerTitleColor = .clear
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)
        calendar.appearance.titleDefaultColor = .black
            
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 18)
        calendar.appearance.weekdayTextColor = .black
        
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.subtitleTodayColor = UIColor(named: "SecondaryColor")
        
        return calendar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        
        title = habit?.name
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .done, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = changeButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    private func createChangeButtonView() -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let button = UIButton(type: .custom)
        button.frame = containerView.bounds
        button.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)

        let iconImageView = UIImageView(image: UIImage(systemName: "slider.horizontal.3"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .black

        let label = UILabel()
        label.text = "Изменить"
        label.font = UIFont.systemFont(ofSize: 14)

        containerView.addSubview(button)
        button.addSubview(iconImageView)
        button.addSubview(label)

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(button)
            make.leading.equalTo(button)
            make.width.height.equalTo(24)
        }

        label.snp.makeConstraints { make in
            make.centerY.equalTo(button)
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalTo(button)
        }

        return containerView
    }

    @objc private func changeButtonTapped() {
        print("Change button tapped")
    }
    
    private func createLabelStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.layer.cornerRadius = 10
        return stackView
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(firstRectangleStackView)
        view.addSubview(secondRectangleStackView)
        view.addSubview(calendar)
        
        firstRectangleStackView.addArrangedSubview(goalTitle)
        firstRectangleStackView.addArrangedSubview(goalToday)
        firstRectangleStackView.addArrangedSubview(streak)
        goalTitle.text = "Цель на сегодня"
        goalToday.text = habit?.goal
        streak.text = "Серия успехов: 0"
        
        secondRectangleStackView.addArrangedSubview(endTitle)
        secondRectangleStackView.addArrangedSubview(todayLabel)
        secondRectangleStackView.addArrangedSubview(weekLabel)
        endTitle.text = "Привычка завершена"
        todayLabel.text = "Сегодня: 3"
        weekLabel.text = "Эта неделя: 0"
        
        updateCalendarAppearance()
    }
    
    private func updateCalendarAppearance() {
        calendar.reloadData()
        
        for date in completedDates {
            calendar.select(date)
            calendar.appearance.titleDefaultColor = .black
            calendar.appearance.selectionColor = UIColor(named: "SecondaryColor")
        }
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        firstRectangleStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(190)
        }

        secondRectangleStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalTo(firstRectangleStackView.snp.trailing).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(190)
        }

        calendar.snp.makeConstraints { make in
            make.top.equalTo(firstRectangleStackView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(400)
            make.height.equalTo(260)
        }
        
        goalTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(40)
        }
            
        goalToday.snp.makeConstraints { make in
            make.top.equalTo(goalTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
            
        streak.snp.makeConstraints { make in
            make.top.equalTo(goalToday.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        endTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(40)
        }
            
        todayLabel.snp.makeConstraints { make in
            make.top.equalTo(goalTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
            
        weekLabel.snp.makeConstraints { make in
            make.top.equalTo(goalToday.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}
