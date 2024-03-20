//
//  NotificationsViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 14.03.2024.
//

import UIKit
import SnapKit

class NotificationsViewController: UIViewController {
    private var notificationItems: [[NotificationItem]] = []
    private var collectionViewArray: [UICollectionView] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let width: CGFloat = 398
        let height: CGFloat = 47
        layout.itemSize = CGSize(width: width, height: height)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NotificationCell.self, forCellWithReuseIdentifier: NotificationCell.identifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Уведомления"
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow_back"), style: .done, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        setupUI()
        generateDummyData()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func generateDummyData() {
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
            
        let todayItems = [
            NotificationItem(habitTitle: "Morning Exercise", subTitle: "Get active in the morning", time: "08:00 AM", date: today),
            NotificationItem(habitTitle: "Drink Water", subTitle: "Stay hydrated throughout the day", time: "10:30 AM", date: today),
        ]
            
        let yesterdayItems = [
            NotificationItem(habitTitle: "Read a Book", subTitle: "Spend time reading before bed", time: "09:00 PM", date: yesterday),
            // Add more items as needed
        ]
            
        let twoDaysAgoItems = [
            NotificationItem(habitTitle: "Meditation", subTitle: "Practice mindfulness", time: "07:00 AM", date: twoDaysAgo),
                // Add more items as needed
        ]
            
        notificationItems = [todayItems, yesterdayItems, twoDaysAgoItems]
        collectionView.reloadData()
    }

    
    @objc private func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
}

extension NotificationsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return notificationItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notificationItems[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationCell.identifier, for: indexPath) as? NotificationCell else {
            return UICollectionViewCell()
        }
        let item = notificationItems[indexPath.section][indexPath.item]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80) // Adjust height as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        let sectionDate = notificationItems[indexPath.section].first?.date ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy" // Choose the desired date format
        let sectionDateString = dateFormatter.string(from: sectionDate)
        headerView.configure(with: sectionDateString)
        return headerView
    }
}


class SectionHeaderView: UICollectionReusableView {
    
    static let identifier = "SectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
