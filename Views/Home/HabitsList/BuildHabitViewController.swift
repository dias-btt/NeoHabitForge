//
//  BuildHabitViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 11.03.2024.
//

import UIKit
import SnapKit
import Foundation

class BuildHabitViewController: UIViewController, AddHabitDelegate{
    
    var networkManager = NetworkManager()
    
    var habits: [HabitCreateResponse]?
    var existingHabits: [ExistingHabit] = []

    var updateCollectionView: (() -> Void) = {}
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let width: CGFloat = 189
        let height: CGFloat = 115
        
        layout.itemSize = CGSize(width: width, height: height)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GoalCardCell.self, forCellWithReuseIdentifier: "HabitCardCell")
        return collectionView
    }()
    
    private let addHabitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать свою привычку", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(addHabitButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        fetchExistingHabitCategoryList()
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .done, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func setupConstraints(){
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(600)
        }
        
        addHabitButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(addHabitButton)
    }
    
    private func fetchExistingHabitCategoryList() {
        networkManager.fetchExistingHabitCategoryList { [weak self] result in
            switch result {
            case .success(let habit):
                self?.existingHabits = habit
                DispatchQueue.main.async{
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch deadline list: \(error)")
            }
        }
    }
        
    @objc private func addHabitButtonTapped(){
        let addHabitViewController = AddHabitViewController()
        addHabitViewController.delegate = self
        addHabitViewController.navigationItem.title = "Создать привычку"
        let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "arrow_back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "arrow_back")
        
        navigationController?.pushViewController(addHabitViewController, animated: true)
    }
    
    func didSaveHabit(name: String, selectedDays: [Int], selectedTime: String?, selectedGoal: String, selectedDeadline: Int, reminder: Bool?, selectedIcon: Int?, selectedColor: Int) {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        
        networkManager.createHabit(
            accessToken: accessToken,
            habitName: name,
            days: selectedDays,
            customTime: selectedTime ?? "",
            goal: selectedGoal,
            deadline: selectedDeadline,
            reminder: reminder ?? false,
            iconImage: selectedIcon ?? 1,
            color: selectedColor
        ) { result in
            switch result {
            case .success(let habit):
                self.habits?.append(habit)
                DispatchQueue.main.async{
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error creating habit: \(error)")
            }
        }
    }
}

extension BuildHabitViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return existingHabits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! GoalCardCell
        let habit = existingHabits[indexPath.item]
        cell.titleLabel.text = habit.name
        cell.iconImageView.sd_setImage(with: URL(string: habit.image), placeholderImage: UIImage(named: "placeholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHabit = existingHabits[indexPath.item]
        let existingHabitsViewController = ExistingHabitsViewController()
        existingHabitsViewController.habit = selectedHabit
        navigationController?.pushViewController(existingHabitsViewController, animated: true)
    }
}
