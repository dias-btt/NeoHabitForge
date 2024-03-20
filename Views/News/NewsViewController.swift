//
//  NewsViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 11.03.2024.
//

import UIKit
import SnapKit

protocol NewsSelectionDelegate: AnyObject {
    func didSelectNews(_ news: HabitArticleList)
}

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NewsSelectionDelegate {

    private var networkManager = NetworkManager()
    private var articleData: [HabitArticleList] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let width: CGFloat = 189
        let height: CGFloat = 281
        
        layout.itemSize = CGSize(width: width, height: height)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: "NewsCell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        collectionView.delegate = self
        collectionView.dataSource = self

        fetchHabitArticleList()
    }
    
    private func setupUI(){
        view.addSubview(collectionView)
    }
    
    private func setupConstraints(){
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func didSelectNews(_ news: HabitArticleList) {
        print("here are news \(news)")
        let newsDetailViewController = NewsReadViewController()
        newsDetailViewController.news = news
        navigationController?.pushViewController(newsDetailViewController, animated: true)
    }

    private func fetchHabitArticleList() {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        networkManager.getHabitArticleList(accessToken: accessToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self.articleData = articles
                    self.collectionView.reloadData()
                case .failure(let error):
                    print("Error fetching habit article list: \(error)")
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: articleData[indexPath.row])
        cell.delegate = self
        return cell
    }
}

