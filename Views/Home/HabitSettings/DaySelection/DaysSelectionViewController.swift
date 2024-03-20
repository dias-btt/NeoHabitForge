//
//  DaysSelectionViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit

protocol DaysSelectionDelegate: AnyObject {
    func didSelectDays(_ selectedDays: [String])
}

class DaysSelectionViewController: UIViewController {
    weak var delegate: DaysSelectionDelegate?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var selectedDays: [String]? {
        didSet{
            updateSelectedDays()
        }
    }
    
    var onSave: (([String]) -> Void)?
    
    private let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 15
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.addTarget(self, action: #selector(saveDaysButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 40
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Выберите дни"

        setupUI()
        setupConstraints()
        setupDayCircles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedDays()
    }

    private func setupUI() {
        buttonStackView.addArrangedSubview(dismissButton)
        buttonStackView.addArrangedSubview(saveButton)
        view.addSubview(buttonStackView)
    }

    private func setupConstraints() {
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
    }

    @objc func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveDaysButtonTapped() {
        print("saving")
        dismiss(animated: true) {
            self.onSave?(self.selectedDays ?? [])
        }
    }
    
    private func setupDayCircles() {
        let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

        for day in daysOfWeek {
            let dayCircleView = createDayCircleView(day: day)
            daysStackView.addArrangedSubview(dayCircleView)
            dayCircleView.snp.makeConstraints { make in
                make.width.height.equalTo(40)
            }
        }

        view.addSubview(daysStackView)
        daysStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
    
    private func updateSelectedDays() {
        guard let selectedDays = selectedDays else {
            return
        }

        for subview in daysStackView.subviews {
            if let dayCircleView = subview as? DayCircleView {
                let day = dayCircleView.day
                dayCircleView.isSelected = selectedDays.contains(day)
            }
        }
        delegate?.didSelectDays(selectedDays)
    }
    
    func didSelectDays(_ selectedDays: [String]) {
        self.selectedDays = selectedDays
    }
    
    private func createDayCircleView(day: String) -> DayCircleView {
           let dayCircleView = DayCircleView(day: day)
           dayCircleView.onTap = { [weak self] in
               guard let self = self else { return }
               if let index = self.selectedDays?.firstIndex(of: day) {
                   self.selectedDays?.remove(at: index)
                   dayCircleView.isSelected = false
               } else {
                   self.selectedDays?.append(day)
                   dayCircleView.isSelected = true
               }
           }
           return dayCircleView
       }

}

