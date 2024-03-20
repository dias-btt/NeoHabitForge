//
//  GoalCollectionView.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 12.03.2024.
//

import UIKit

class GoalsCollectionView: UICollectionView {
    var goals: [Goal] = [] {
        didSet {
            reloadData()
        }
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let width: CGFloat = 189
        let height: CGFloat = 115
        
        layout.itemSize = CGSize(width: width, height: height)
        
        self.init(frame: .zero, collectionViewLayout: layout)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        dataSource = self
        delegate = self
        register(GoalCardCell.self, forCellWithReuseIdentifier: "GoalCardCell")
    }
}

extension GoalsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
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
}
