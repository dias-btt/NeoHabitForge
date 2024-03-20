import UIKit
import SnapKit

protocol ResultCellDelegate: AnyObject {
    func checkboxTapped(for cell: ResultCell)
}

class ResultCell: UICollectionViewCell {
    weak var delegate: ResultCellDelegate?
    var habit: HabitList?
    private var networkManager = NetworkManager()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    let checkboxButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 17
        button.setImage(UIImage(named: "habit_unchecked"), for: .normal)
        button.setImage(UIImage(named: "habit_checked"), for: .selected)
        button.clipsToBounds = true
        return button
    }()
    var checkboxTappedAction: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkboxButton)
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView).offset(8)
            make.width.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(8)
        }
        
        checkboxButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-8)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(34)
        }
        
        contentView.backgroundColor = UIColor(named: "SecondaryColor")
        contentView.layer.cornerRadius = 10
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }
    
    func configure(with habit: HabitList) {
        self.habit = habit
        titleLabel.text = habit.name
        fetchIconList(for: habit.id) { imageURL in
            if let imageURL = imageURL {
                self.iconImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder"))
            } else {
                self.iconImageView.image = UIImage(named: "placeholder")
            }
        }
        checkboxButton.isSelected = habit.is_completed
    }
    
    @objc private func checkboxTapped() {
        guard var habit = habit else {
            return
        }
        habit.is_completed.toggle()
        checkboxButton.isSelected = habit.is_completed
        if habit.is_completed {
            completeHabit(selectedHabit: habit)
        }
        delegate?.checkboxTapped(for: self)
    }
    
    private func completeHabit(selectedHabit: HabitList){
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        networkManager.habitComplete(accessToken: accessToken, habitID: selectedHabit.id) { [weak self] error in
            if let error = error {
                print("Error creating existing habit: \(error)")
            } else {
            }
        }
    }
    
    private func fetchIconList(for id: Int, completion: @escaping (String?) -> Void) {
        networkManager.fetchIconList { [weak self] result in
            switch result {
            case .success(let icons):
                if let icon = icons.first(where: { $0.id == id }) {
                    completion(icon.image)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("Failed to fetch icon list: \(error)")
                completion(nil)
            }
        }
    }
}
