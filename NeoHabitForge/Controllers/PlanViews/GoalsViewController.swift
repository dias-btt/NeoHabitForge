//
//  GoalsViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 28.02.2024.
//
import UIKit

protocol GoalsViewControllerDelegate: AnyObject {
    func nextPageRequested()
}

class GoalsViewController: UIViewController {
    weak var delegate: GoalsViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Какова ваша цель?"
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Мы создадим для вас персональный план достижений."
        return label
    }()
    
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
        collectionView.register(GoalCardCell.self, forCellWithReuseIdentifier: "GoalCardCell")
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

    var selectedGoals: [Goal] = []
    private var goals: [Goal] = [
        Goal(title: "Здоровый образ жизни", icon: UIImage(named: "image 1-2")!),
        Goal(title: "Снять стресс", icon: UIImage(named: "image 1-3")!),
        Goal(title: "Добиться большей сосредоточенности", icon: UIImage(named: "image 1-4")!),
        Goal(title: "Крепкий сон", icon: UIImage(named: "image 1-5")!),
        Goal(title: "Избавиться от вредных привычек", icon: UIImage(named: "image 1-6")!),
        Goal(title: "Правильное питание", icon: UIImage(named: "image 1-7")!),
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
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(40)
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
        view.addSubview(subTitleLabel)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
    }
    
    @objc func nextButtonTapped() {
        if !selectedGoals.isEmpty{
            delegate?.nextPageRequested()
        }
    }
}

extension GoalsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalCardCell", for: indexPath) as! GoalCardCell
        let goal = goals[indexPath.item]
        cell.iconImageView.image = goal.icon
        cell.titleLabel.text = goal.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGoal = goals[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) as? GoalCardCell {
            if selectedGoals.contains(where: { $0 == selectedGoal }) {
                if let index = selectedGoals.firstIndex(of: selectedGoal) {
                    selectedGoals.remove(at: index)
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
                selectedGoals.append(selectedGoal)
                cell.backgroundColor = UIColor(named: "SecondaryColor")
                cell.titleLabel.textColor = .white
                cell.iconImageView.tintColor = .white
            }
        }
    }

}

struct Goal: Equatable {
    let title: String
    let icon: UIImage
}

class GoalCardCell: UICollectionViewCell {
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
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layer.cornerRadius = 10
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
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}
