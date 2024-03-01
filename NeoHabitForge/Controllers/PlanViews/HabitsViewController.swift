//
//  HabitsViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 29.02.2024.
//

import UIKit

class HabitsViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Выберите одну или несколько привычек которые хотите выработать"
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let width: CGFloat = 400
        let height: CGFloat = 69
        
        layout.itemSize = CGSize(width: width, height: height)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HabitCardCell.self, forCellWithReuseIdentifier: "HabitCardCell")
        return collectionView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Далее", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    var selectedHabits: [Habit] = []
    private var habits: [Habit] = [
        Habit(title: "Ходьба", icon: UIImage(named: "image 2")!),
        Habit(title: "Пить больше воды", icon: UIImage(named: "image 2-2")!),
        Habit(title: "Делать упражнения", icon: UIImage(named: "image 2-3")!),
        Habit(title: "Заняться йогой", icon: UIImage(named: "image 2-4")!)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func setupConstraints(){
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(600)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            make.width.equalTo(400)
            make.height.equalTo(50)
        }
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
    }
    
    @objc func nextButtonTapped() {
        if !selectedHabits.isEmpty{
            let planViewController = PlanLoadingViewController()
            navigationController?.pushViewController(planViewController, animated: true)
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}

extension HabitsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return habits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! HabitCardCell
        let habit = habits[indexPath.item]
        cell.iconImageView.image = habit.icon
        cell.titleLabel.text = habit.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHabit = habits[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) as? HabitCardCell {
            if selectedHabits.contains(where: { $0 == selectedHabit }) {
                if let index = selectedHabits.firstIndex(of: selectedHabit) {
                    selectedHabits.remove(at: index)
                }
                cell.backgroundColor = .clear
                cell.layer.cornerRadius = 10
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
            
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOpacity = 0.05
                cell.layer.shadowOffset = CGSize(width: 10, height: 10)
                cell.layer.shadowRadius = 20
                
                cell.titleLabel.textColor = .black
            } else {
                selectedHabits.append(selectedHabit)
                cell.backgroundColor = UIColor(named: "SecondaryColor")
                cell.titleLabel.textColor = .white
                cell.iconImageView.tintColor = .white
            }
        }
    }

}

struct Habit: Equatable {
    let title: String
    let icon: UIImage
}

class HabitCardCell: UICollectionViewCell {
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layer.cornerRadius = 15
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
            make.leading.equalToSuperview().offset(10) // Align to the leading edge with a margin of 10
            make.centerY.equalToSuperview() // Center vertically
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview() // Center vertically
            make.leading.equalTo(iconImageView.snp.trailing).offset(20) // Align to the trailing edge of the icon with a margin of 20
            make.trailing.equalToSuperview().inset(10) // Align to the trailing edge with a margin of 10
        }
    }
}

