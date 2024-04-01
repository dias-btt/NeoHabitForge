//
//  OnboardingViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 27.02.2024.
//
import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let pages: [(imageName: String, boldText: String, regularText: String)] = [
        ("onboarding-1", "Ваш путь к лучшей версии себя", "Отправьтесь в захватывающее путешествие личного развития с мобильным приложением 'Трекер привычек'."),
        ("onboarding-2", "Устанавливай, Созидай, Достигай!", "Установите цели, создавайте здоровые привычки и следите за своим прогрессом с интуитивно понятным интерфейсом."),
        ("onboarding-3", "Перезапустите свою Жизнь", "Приготовьтесь к путешествию к новой жизни, полной достижений и положительных изменений!")
    ]
    
    private var currentPageIndex = 0
    
    private let pageIndicatorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")
        
        setupPageIndicator()
        navigationItem.hidesBackButton = true
    }
    
    func setupViews(){
        view.addSubview(collectionView)
        view.addSubview(pageIndicatorStackView)
        view.addSubview(nextButton)
    }
    
    func setupConstraints(){
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageIndicatorStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
            make.width.equalTo(400)
            make.height.equalTo(50)
        }
    }
    
    private func setupPageIndicator() {
        for _ in pages {
            let indicatorView = UIView()
            indicatorView.backgroundColor = .gray
            indicatorView.layer.cornerRadius = 2
            pageIndicatorStackView.addArrangedSubview(indicatorView)
            indicatorView.snp.makeConstraints { make in
                make.width.equalTo(25)
                make.height.equalTo(4)
            }
        }
        updatePageIndicator()
    }
    
    private func updatePageIndicator() {
        for (index, subview) in pageIndicatorStackView.arrangedSubviews.enumerated() {
            if let indicatorView = subview as? UIView {
                if currentPageIndex == 0 {
                    pageIndicatorStackView.isHidden = false
                    nextButton.isHidden = true
                    indicatorView.backgroundColor = (index == 0) ? UIColor(named: "SecondaryColor") : .gray
                } else if currentPageIndex == 1 {
                    pageIndicatorStackView.isHidden = false
                    nextButton.isHidden = true
                    indicatorView.backgroundColor = (index <= 1) ? UIColor(named: "SecondaryColor") : .gray
                } else {
                    nextButton.isHidden = false
                    pageIndicatorStackView.isHidden = true
                }
            }
        }
    }
    
    @objc func nextButtonTapped() {
        let planViewController = PlanViewController()
        navigationController?.pushViewController(planViewController, animated: true)
    }
}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        let page = pages[indexPath.item]
        cell.configure(imageName: page.imageName, boldText: page.boldText, regularText: page.regularText)
        return cell
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width != 0 else {
            return
        }

        let pageIndex = max(min(Int(round(scrollView.contentOffset.x / scrollView.frame.width)), pages.count - 1), 0)
        if currentPageIndex != pageIndex {
            currentPageIndex = pageIndex
            updatePageIndicator()
        }
    }

}

class OnboardingCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let boldTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Ubuntu-Medium", size: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let regularTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Ubuntu-Regular", size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(boldTextLabel)
        contentView.addSubview(regularTextLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(430)
            make.height.equalTo(365)
        }
        
        boldTextLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        regularTextLabel.snp.makeConstraints { make in
            make.top.equalTo(boldTextLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageName: String, boldText: String, regularText: String) {
        imageView.image = UIImage(named: imageName)
        boldTextLabel.text = boldText
        regularTextLabel.text = regularText
    }
}
