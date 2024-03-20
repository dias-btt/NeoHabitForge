//
//  AddHabitViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit

protocol AddHabitDelegate: AnyObject {
    func didSaveHabit(name: String, selectedDays: [Int], selectedTime: String?, selectedGoal: String, selectedDeadline: Int, reminder: Bool?, selectedIcon: Int?, selectedColor: Int)
}

class AddHabitViewController: UIViewController, DaysSelectionDelegate, GoalsSelectionDelegate, IconSelectionDelegate, ColorSelectionDelegate, SectionViewDelegate, UITextFieldDelegate {
    weak var delegate: AddHabitDelegate?
    
    private var deadlineList: [Deadline] = []
    
    private let nameTextField = CustomTextField(placeholder: "Введите название привычки")
    private var selectedTime: String?
    var selectedDays: [String] = []
    var selectedGoal: String = ""
    var selectedIcon: Icon?
    var selectedColor: Color?
    var notify: Bool = false
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var chooseTimeView: UIStackView = createTimeStackView()
    let daysSection = SectionView(title: "Повторение", subtitle: "Дни повторения", target: self, action: #selector(openDaysSelection))
    let iconsSection = SectionView(title: "Выбрать иконку", subtitle: "Иконка", target: self, action: #selector(openIconsSelection))
    let colorsSection = SectionView(title: "Выбрать цвет", subtitle: "Цвет", target: self, action: #selector(openColorsSelection))
    let notifySection = SectionView(title: "Напоминание", subtitle: "Напоминание для этой привычки", target: self, action: #selector(openNotifySelection), notify: true)

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var iconSelectionViewController: IconSelectionViewController = {
        let iconSelectionVC = IconSelectionViewController()
        iconSelectionVC.delegate = self
        return iconSelectionVC
    }()
    
    private lazy var colorSelectionViewController: ColorSelectionViewController = {
        let colorSelectionVC = ColorSelectionViewController()
        colorSelectionVC.delegate = self
        return colorSelectionVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        notifySection.delegate = self
        nameTextField.delegate = self
        updateSaveButtonState()
        fetchDeadlineList()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        
        scrollStackViewContainer.addArrangedSubview(nameTextField)
        scrollStackViewContainer.addArrangedSubview(daysSection)
        
        view.addSubview(chooseTimeView)
                
        let goalsSection = SectionView(title: "Установить цель", subtitle: "Ваша цель", target: self, action: #selector(openGoalsSelection))
        scrollStackViewContainer.addArrangedSubview(goalsSection)
        scrollStackViewContainer.addArrangedSubview(iconsSection)
        scrollStackViewContainer.addArrangedSubview(colorsSection)
        scrollStackViewContainer.addArrangedSubview(notifySection)
        scrollStackViewContainer.addArrangedSubview(saveButton)
        scrollStackViewContainer.spacing = 40
    }

    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollStackViewContainer.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
            make.bottom.equalToSuperview().inset(20)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        chooseTimeView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(270)
        }
        
        var previousSectionView: UIView?

        scrollStackViewContainer.subviews.compactMap { $0 as? SectionView }.enumerated().forEach { index, section in
            section.snp.makeConstraints { make in
                if let previousView = previousSectionView {
                    make.top.equalTo(previousView.snp.bottom).offset(40)
                } else {
                    make.top.equalTo(chooseTimeView.snp.bottom).offset(20)
                }
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(100)
            }

            previousSectionView = section
        }
    }
    
    private func fetchDeadlineList() {
        let networkManager = NetworkManager()
        networkManager.fetchDeadlineList { [weak self] result in
            switch result {
            case .success(let deadlines):
                self?.deadlineList = deadlines
            case .failure(let error):
                print("Failed to fetch deadline list: \(error)")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didSelectDays(_ selectedDays: [String]) {
        self.selectedDays = selectedDays

        if self.selectedDays.count == 7 {
            daysSection.update(with: "Каждый день")
        } else {
            let daysString = selectedDays.joined(separator: ", ")
            daysSection.update(with: daysString)
        }
    }

    @objc private func openDaysSelection() {
        let daysSelectionVC = DaysSelectionViewController()
        daysSelectionVC.modalPresentationStyle = .custom
        daysSelectionVC.transitioningDelegate = self
        daysSelectionVC.delegate = self
        daysSelectionVC.selectedDays = selectedDays
        present(daysSelectionVC, animated: true, completion: nil)
    }
    
    func didSelectGoal(_ selectedGoal: String) {
        self.selectedGoal = selectedGoal
        updateSaveButtonState()
    }
    
    func didChangeGoalText(_ goalText: String) {
    }
    
    @objc private func openGoalsSelection() {
        let goalsSelectionVC = GoalsSelectionViewController()
        goalsSelectionVC.modalPresentationStyle = .custom
        goalsSelectionVC.transitioningDelegate = self
        goalsSelectionVC.delegate = self
        goalsSelectionVC.selectedGoal = selectedGoal
        present(goalsSelectionVC, animated: true, completion: nil)
    }
    
    @objc private func openColorsSelection() {
        colorSelectionViewController.modalPresentationStyle = .custom
        colorSelectionViewController.transitioningDelegate = self
        present(colorSelectionViewController, animated: true, completion: nil)
    }
    
    func didSelectColor(_ selectedColor: Color) {
        self.selectedColor = selectedColor
        colorsSection.update(with: selectedColor)
        updateSaveButtonState()
    }
    
    @objc private func openIconsSelection() {
        iconSelectionViewController.modalPresentationStyle = .custom
        iconSelectionViewController.transitioningDelegate = self
        present(iconSelectionViewController, animated: true, completion: nil)
    }

    func didSelectIcon(_ selectedIcon: Icon) {
        self.selectedIcon = selectedIcon
        iconsSection.update(with: selectedIcon)
        updateSaveButtonState()
    }
    
    @objc private func openNotifySelection() {
        //nothing
    }
    
    func toggleSwitchValueChanged(isOn: Bool) {
        self.notify = isOn
    }
    
    func convertDaysToIntegers(days: [String]) -> [Int] {
        let dayMapping: [String: Int] = [
            "Пн": 2,
            "Вт": 3,
            "Ср": 4,
            "Чт": 5,
            "Пт": 6,
            "Сб": 7,
            "Вс": 8
        ]
        
        var dayNumbers: [Int] = []
        
        for day in days {
            if let dayNumber = dayMapping[day] {
                dayNumbers.append(dayNumber)
            }
        }
        
        return dayNumbers
    }

    
    @objc private func saveButtonTapped(){
        var selectedDay: [Int]?
        if selectedDays.count == 7 {
            selectedDay = [1]
        } else {
            selectedDay = convertDaysToIntegers(days: selectedDays)
        }
        
        guard let text = nameTextField.text else {
            nameTextField.showWarning(true)
            return
        }
            
        delegate?.didSaveHabit(name: text, selectedDays: selectedDay ?? [1], selectedTime: selectedTime, selectedGoal: selectedGoal, selectedDeadline: 1, reminder: notify, selectedIcon: selectedIcon?.id, selectedColor: selectedColor?.id ?? 1)
            navigationController?.popViewController(animated: true)
    }
    
    private func updateSaveButtonState() {
        let isNameFilled = !(nameTextField.text?.isEmpty ?? true)
        let isIconSelected = selectedIcon != nil
        let isColorSelected = selectedColor != nil
        let isGoalSelected = !selectedGoal.isEmpty
        let isTimeSelected = selectedTime != nil

        let isEnabled = isNameFilled && isIconSelected && isColorSelected && isGoalSelected && isTimeSelected

        saveButton.isEnabled = isEnabled
        saveButton.backgroundColor = isEnabled ? UIColor(named: "SecondaryColor") : UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
    }
    
    private func presentSelectionViewController(_ viewController: UIViewController) {
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
    
    private func createTimeStackView() -> UIStackView {
        let chooseTimeView = UIStackView()
        chooseTimeView.axis = .vertical
        chooseTimeView.distribution = .fillEqually
        chooseTimeView.spacing = 20

        var selectedTimeView: ChooseTimeView?
        var timeViews: [ChooseTimeView] = []

        for (time, iconName, sub) in [("В любое время", "anytime", ""), ("Только Утром", "morning", "8:00-11:00"), ("Только Днем", "day", "12:00-15:00"), ("Только Вечером", "night", "16:00-19:00")] {
            let icon = UIImage(named: iconName)
            let timeView = ChooseTimeView(time: time, icon: icon, subTitle: sub)
            timeViews.append(timeView)

            timeView.onTap = { [weak self] in
                guard let self = self else { return }
                if time == "В любое время" {
                    let timePickerVC = TimePickerViewController()
                    timePickerVC.delegate = self
                    timePickerVC.selectedTime = self.selectedTime
                    self.present(timePickerVC, animated: true, completion: nil)
                } else {
                    self.selectedTime = time
                    selectedTimeView?.isSelected = false
                    selectedTimeView = timeView
                    selectedTimeView?.isSelected = true
                }
            }
        }

        var horizontalStackView: UIStackView?
        for (index, timeView) in timeViews.enumerated() {
            if index % 2 == 0 {
                horizontalStackView = UIStackView()
                horizontalStackView?.axis = .horizontal
                horizontalStackView?.distribution = .fillEqually
                horizontalStackView?.spacing = 20
            }
            horizontalStackView?.addArrangedSubview(timeView)

            if (index + 1) % 2 == 0 || index == timeViews.count - 1 {
                if let horizontalStackView = horizontalStackView {
                    chooseTimeView.addArrangedSubview(horizontalStackView)
                }
            }
        }

        return chooseTimeView
    }
}

extension AddHabitViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is IconSelectionViewController {
            return IconSelectionPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is ColorSelectionViewController{
            return ColorSelectionPresentationController(presentedViewController: presented, presenting: presenting)
        } else {
            return HalfScreenPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
}

extension AddHabitViewController: TimePickerViewControllerDelegate {
        func nextPageRequested(selectedTime: String) {
            self.selectedTime = selectedTime
            dismiss(animated: true, completion: nil)
    }
}
