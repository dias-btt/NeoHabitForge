//
//  ColorSelectionViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit
import SnapKit

protocol ColorSelectionDelegate: AnyObject {
    func didSelectColor(_ selectedColor: Color)
}

class ColorSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: ColorSelectionDelegate?
    private var networkManager = NetworkManager()
    var colorList: [Color]?
    
    private let colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let colorOptions: [UIColor] = [
        .red, .blue, .green, .yellow, .orange, .purple, .cyan, .brown
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        fetchColorList()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 10

        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
        colorsCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        view.addSubview(colorsCollectionView)
        
        if let flowLayout = colorsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing: CGFloat = 32
            let insets: CGFloat = 32
            let itemWidth = (UIScreen.main.bounds.width - insets * 2 - spacing * 3) / 4 // For 4 items in a row
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.minimumLineSpacing = spacing
            flowLayout.sectionInset = UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }

    private func setupConstraints() {
        colorsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func fetchColorList() {
        networkManager.fetchColorList { [weak self] result in
            switch result {
            case .success(let colors):
                self?.colorList = colors
                DispatchQueue.main.async{
                    self?.colorsCollectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch deadline list: \(error)")
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCollectionViewCell else {
            fatalError("Failed to dequeue ColorCollectionViewCell")
        }

        let color = colorList?[indexPath.item]
        if let hexColor = UIColor(hexString: color?.name ?? "") {
            cell.configure(with: hexColor)
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedColor = colorList?[indexPath.item]{
            delegate?.didSelectColor(selectedColor)
        }
        dismiss(animated: true, completion: nil)
    }
}

class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionViewCell"

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
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
        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
