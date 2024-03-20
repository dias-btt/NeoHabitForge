//
//  NewsReadViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//
import UIKit
import SnapKit

class NewsReadViewController: UIViewController {
    var news: HabitArticleList?
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    private let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = news?.title
        setupUI()
        let backButtonImage = UIImage(named: "arrow_back")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonPressed))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupUI(){
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let articleID = news?.id {
            fetchArticleContent(articleID: articleID)
        }
    }
    
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    private func fetchArticleContent(articleID: Int) {
        networkManager.fetchArticleContent(articleID: articleID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let articleDetail):
                DispatchQueue.main.async {
                    self.textView.text = articleDetail.content
                }
            case .failure(let error):
                print("Error fetching article content: \(error)")
            }
        }
    }
}


