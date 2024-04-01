import UIKit
import FSCalendar
import SnapKit

protocol HomeViewControllerDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class HomeViewController: UIViewController, ResultCellDelegate, BuildHabitDelegate {
    
    weak var delegate: HomeViewControllerDelegate?
    
    private var selectedDate: Date?
    private var networkManager = NetworkManager()
    
    private var habits: [HabitCreateResponse] = []
    private var uiHabits: [HabitList] = []
    
    private lazy var congratulationsViewController: CongratulationsViewController = {
        let iconSelectionVC = CongratulationsViewController()
        return iconSelectionVC
    }()
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "avatar")
        return imageView
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let timeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Привет "
        return label
    }()
    
    private let calendarWrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.scope = .week
        calendar.locale = Locale(identifier: "ru_RU")
        
        calendar.appearance.headerTitleColor = .clear
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)
        calendar.appearance.titleDefaultColor = .black
            
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 18)
        calendar.appearance.weekdayTextColor = .black
        
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.selectionColor = UIColor(named: "SecondaryColor")
        calendar.appearance.subtitleTodayColor = UIColor(named: "SecondaryColor")
        return calendar
    }()
    
    private lazy var noHabitsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no-habits")
        imageView.isHidden = true
        return imageView
    }()
    
    private let noHabitsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = UIColor(named: "ThirdColor")
        label.text = "Вы еще не создали свою первую привычку"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let addHabitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать привычку", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(addHabitButtonTapped), for: .touchUpInside)
        return button
    }()
        
    private let resultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        updateTimeBasedComponents()
        navigationItem.hidesBackButton = true
        networkManager.refreshAccessTokenIfNeeded { result in
            switch result {
            case .success(let accessToken):
                self.fetchUserInfo()
            case .failure(let error):
                print("Failed to refresh access token: \(error)")
            }
        }
        resultsCollectionView.register(ResultCell.self, forCellWithReuseIdentifier: "ResultCell")
        resultsCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        fetchUserInfo()
        calendar.select(Date())
        fetchHabits(for: selectedDate ?? Date())
    }
    
    private func fetchUserInfo() {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults....")
            return
        }
        networkManager.getUserInfo(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.helloLabel.text = "Привет, \(user.first_name ?? "")"
                    self?.profileImageView.image = UIImage(named: user.image ?? "avatar")
                }
            case .failure(let error):
                print("Failed to fetch user information: \(error)")
            }
        }
    }
    
    private func fetchHabits(for date: Date) {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: date)
        
        let dayAbbreviation: String
        switch dayOfWeekString {
            case "понедельник": dayAbbreviation = "ПН"
            case "вторник": dayAbbreviation = "ВТ"
            case "среда": dayAbbreviation = "СР"
            case "четверг": dayAbbreviation = "ЧТ"
            case "пятница": dayAbbreviation = "ПТ"
            case "суббота": dayAbbreviation = "СБ"
            case "воскресенье": dayAbbreviation = "ВС"
            default: dayAbbreviation = ""
        }
        
        networkManager.fetchHabitList(accessToken: accessToken, date: dayAbbreviation) { result in
            switch result {
            case .success(let fetchedHabits):
                self.uiHabits = fetchedHabits
                DispatchQueue.main.async {
                    self.resultsCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching habits: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(greetingLabel)
        view.addSubview(timeIconImageView)
        view.addSubview(helloLabel)
        view.addSubview(addHabitButton)
        view.addSubview(resultsCollectionView)
        view.addSubview(noHabitsImage)
        view.addSubview(noHabitsLabel)
        view.addSubview(calendarWrapperView)
        calendarWrapperView.addSubview(calendar)
            
        calendar.delegate = self
        calendar.dataSource = self
        resultsCollectionView.dataSource = self
        resultsCollectionView.delegate = self
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(48)
        }
        
        timeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.width.height.equalTo(24)
        }
        
        greetingLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerY.equalTo(timeIconImageView)
            make.leading.equalTo(timeIconImageView.snp.trailing).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        helloLabel.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel.snp.bottom).offset(8)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        calendarWrapperView.snp.makeConstraints { make in
            make.top.equalTo(helloLabel.snp.bottom).offset(40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(160)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(60)
        }
        
        noHabitsImage.snp.makeConstraints { make in
            make.top.equalTo(calendarWrapperView.snp.bottom).offset(40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.width.height.equalTo(270)
        }
        
        noHabitsLabel.snp.makeConstraints { make in
            make.top.equalTo(noHabitsImage.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(80)
            make.centerX.equalToSuperview()
        }
        
        addHabitButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        
        resultsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(calendarWrapperView.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.bottom.equalTo(addHabitButton.snp.top).offset(-10)
        }
    }

    private func updateTimeBasedComponents() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour >= 6 && hour < 12 {
            greetingLabel.text = "Доброе утро"
            timeIconImageView.image = UIImage(named: "sun")
        } else if hour >= 12 && hour < 18 {
            greetingLabel.text = "Добрый день"
            timeIconImageView.image = UIImage(named: "sun")
        } else {
            greetingLabel.text = "Добрый вечер"
            timeIconImageView.image = UIImage(named: "sun")
        }
    }
    
    @objc private func addHabitButtonTapped() {
        let buildHabitViewController = BuildHabitViewController()
        buildHabitViewController.updateCollectionView = { [weak self] in
            self?.resultsCollectionView.reloadData()
        }
        buildHabitViewController.delegate = self
        buildHabitViewController.navigationItem.title = "Создать новую привычку"
        let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "arrow_back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "arrow_back")
        
        navigationController?.pushViewController(buildHabitViewController, animated: true)
    }
    
    func checkboxTapped(for cell: ResultCell) {
        congratulationsViewController.dismissAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        congratulationsViewController.navigationControllerRef = self.navigationController
        congratulationsViewController.modalPresentationStyle = .custom
        congratulationsViewController.transitioningDelegate = self
        present(congratulationsViewController, animated: true, completion: nil)
    }
    
    func mapToUIHabits(_ apiHabits: [HabitCreateResponse]) -> [HabitList] {
        return apiHabits.map { HabitList(id: $0.id ?? 1, name: $0.name ?? "", icon_image: $0.icon_image ?? 1, is_completed: false) }
    }
    
    func mapToExistingHabtis(_ habits: [HabitList]) -> [ExistingHabit]{
        return habits.map {ExistingHabit(id: $0.id, name: $0.name, image: "") }
    }
    
    func didUpdateHabits(_ habits: [HabitCreateResponse]) {
        self.habits = habits
        print("my habits are \(self.habits)")
    }
}

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        DispatchQueue.main.async{
            self.fetchHabits(for: self.selectedDate ?? Date())
        }
        if self.uiHabits.isEmpty {
            noHabitsImage.isHidden = false
            noHabitsLabel.isHidden = false
            resultsCollectionView.isHidden = true
        } else {
            noHabitsImage.isHidden = true
            noHabitsLabel.isHidden = true
            resultsCollectionView.isHidden = false
            DispatchQueue.main.async {
                self.resultsCollectionView.reloadData()
            }
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
            headerView.titleLabel.text = "Результат"
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uiHabits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as! ResultCell

        let habit = uiHabits[indexPath.item]
        cell.configure(with: HabitList(id: habit.id, name: habit.name, icon_image: habit.icon_image, is_completed: false))
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 95)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHabit = uiHabits[indexPath.item]
        let editHabitVC = EditHabitViewController(habit: selectedHabit)
        
        navigationController?.pushViewController(editHabitVC, animated: true)
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return CongratulationsPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
