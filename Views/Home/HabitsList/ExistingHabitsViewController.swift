//
//  ExistingHabitsViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 18.03.2024.
//

//
//  BuildHabitViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 11.03.2024.
//

import UIKit
import SnapKit
import SDWebImage

class ExistingHabitsViewController: UIViewController {
        
    var networkManager = NetworkManager()
    var habit: ExistingHabit?
    var existingHabits: [ExistingHabitsList] = []
    
    var selectedHabit: ExistingHabitsList?

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
        button.setTitle("Создать привычку", for: .normal)
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
        fetchExistingHabiList()
        
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
    
    private func fetchExistingHabiList() {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        
        networkManager.fetchExistingHabitList(accessToken: accessToken, categoryName: habit?.name ?? "") { [weak self] result in
            switch result {
            case .success(let habits):
                self?.existingHabits = habits
                DispatchQueue.main.async{
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch existing habits list: \(error)")
            }
        }
    }
        
    @objc private func addHabitButtonTapped() {
        guard let selectedHabit = selectedHabit else {
            addHabitButton.isEnabled = false
            addHabitButton.backgroundColor = UIColor(red: 0.44, green: 0.89, blue: 0.55, alpha: 1.00)
            return
        }
        
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        
        networkManager.createExistingHabit(accessToken: accessToken, habitID: selectedHabit.id) { error in
            if let error = error {
                print("Error creating habit: \(error)")
            } else {
                DispatchQueue.main.async {
                    let homeViewController = TabBarViewController()
                    self.navigationController?.pushViewController(homeViewController, animated: true)
                }
            }
        }
    }
}

extension ExistingHabitsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return existingHabits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! GoalCardCell
        let habit = existingHabits[indexPath.item]
        cell.titleLabel.text = habit.name
        cell.iconImageView.sd_setImage(with: URL(string: habit.icon_image?.image ?? ""), placeholderImage: UIImage(named: "placeholder"))
        
        if habit == selectedHabit {
            cell.backgroundColor = UIColor(named: "SecondaryColor")
            cell.titleLabel.textColor = .white
            cell.iconImageView.tintColor = .white
        } else {
            cell.backgroundColor = .clear
            cell.titleLabel.textColor = .black
            cell.iconImageView.tintColor = .black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedHabit = existingHabits[indexPath.item]
        collectionView.reloadData()
    }
}
