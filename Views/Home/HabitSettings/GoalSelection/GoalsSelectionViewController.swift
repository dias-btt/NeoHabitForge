//
//  GoalsSelectionViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit

protocol GoalsSelectionDelegate: AnyObject {
    func didChangeGoalText(_ goalText: String)
    func didSelectGoal(_ selectedGoal: String)
}

class GoalsSelectionViewController: UIViewController, UITextFieldDelegate {
    weak var delegate: GoalsSelectionDelegate?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var selectedGoal: String? {
        didSet{
            updateSelectedGoal()
        }
    }
    var onSave: ((String) -> Void)?
    
    private let goalTextField = CustomTextField(placeholder: "Установить цель")
    
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
        button.addTarget(self, action: #selector(saveGoalButtonTapped), for: .touchUpInside)
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
        navigationItem.title = "Ваша цель"
        goalTextField.delegate = self

        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedGoal()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        selectedGoal = textField.text
        delegate?.didChangeGoalText(textField.text ?? "")
    }

    private func setupUI() {
        view.addSubview(goalTextField)
        buttonStackView.addArrangedSubview(dismissButton)
        buttonStackView.addArrangedSubview(saveButton)

        view.addSubview(buttonStackView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    private func setupConstraints() {
        goalTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
    }

    @objc func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveGoalButtonTapped() {
        dismiss(animated: true) {
            self.onSave?(self.selectedGoal ?? "")
        }
    }
    
    private func updateSelectedGoal() {
        guard let selectedGoal = selectedGoal else {
            return
        }

        goalTextField.text = selectedGoal
        
        delegate?.didSelectGoal(selectedGoal)
    }
    
    func didSelectDays(_ selectedGoal: String) {
        self.selectedGoal = selectedGoal
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let percentComplete = abs(translation.y / view.bounds.height)

        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            dismiss(animated: true, completion: nil)

        case .changed:
            interactionController?.update(percentComplete)

        case .ended, .cancelled:
            if percentComplete > 0.5 || gesture.velocity(in: view).y > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil

        default:
            break
        }
    }
}
