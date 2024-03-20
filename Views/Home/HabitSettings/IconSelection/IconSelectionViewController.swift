//
//  IconsSelectionViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//
// IconSelectionViewController.swift

import UIKit
import SnapKit
import SDWebImage

protocol IconSelectionDelegate: AnyObject {
    func didSelectIcon(_ selectedIcon: Icon)
}

class IconSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: IconSelectionDelegate?
    var iconsList: [Icon]?
    let networkManager = NetworkManager()

    private let iconsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        fetchIconList()
        iconsCollectionView.dataSource = self
        iconsCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 32
        layout.minimumLineSpacing = 32
        iconsCollectionView.collectionViewLayout = layout

        iconsCollectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: "IconCell")
        view.addSubview(iconsCollectionView)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        iconsCollectionView.dataSource = self
        iconsCollectionView.delegate = self
        iconsCollectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: "IconCell") // Use a string identifier
        view.addSubview(iconsCollectionView)
    }

    private func setupConstraints() {
        iconsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().offset(32)
        }
    }
    
    private func fetchIconList() {
        networkManager.fetchIconList { [weak self] result in
            switch result {
            case .success(let icons):
                self?.iconsList = icons
                DispatchQueue.main.async{
                    self?.iconsCollectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch deadline list: \(error)")
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.iconsList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCollectionViewCell else {
            fatalError("Failed to dequeue IconCollectionViewCell")
        }

        let iconName = self.iconsList?[indexPath.item]
        if let iconURL = URL(string: iconName?.image ?? "") {
                cell.configure(with: iconURL)
            }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 24, height: 24)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIconName = self.iconsList?[indexPath.item]
        if let selectedIcon = selectedIconName {
            delegate?.didSelectIcon(selectedIcon)
        }
        dismiss(animated: true, completion: nil)
    }
}

class IconCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "IconCollectionViewCell"

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }

    func configure(with iconURL: URL) {
        iconImageView.sd_setImage(with: iconURL, placeholderImage: nil, options: [], completed: nil)
    }
}
