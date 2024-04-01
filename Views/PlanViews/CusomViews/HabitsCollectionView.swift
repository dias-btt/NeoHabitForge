//
//  HabitsCollectionView.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 12.03.2024.
//

import UIKit

class HabitsCollectionView: UICollectionView {
    var habits: [HabitList] = [] {
        didSet {
            reloadData()
        }
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let width: CGFloat = 400
        let height: CGFloat = 69
        
        layout.itemSize = CGSize(width: width, height: height)
        
        self.init(frame: .zero, collectionViewLayout: layout)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        dataSource = self
        delegate = self
        register(HabitCardCell.self, forCellWithReuseIdentifier: "HabitCardCell")
    }
}

extension HabitsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return habits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! HabitCardCell
        let habit = habits[indexPath.item]
        cell.titleLabel.text = habit.name
        return cell
    }
}
