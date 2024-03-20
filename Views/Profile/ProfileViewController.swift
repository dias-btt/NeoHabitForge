//
//  ProfileViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 11.03.2024.
//

import UIKit
import SnapKit
import MobileCoreServices

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var networkManager = NetworkManager()
    var user: UserMe?
    
    private func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "avatar")
        return imageView
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let notificationButton: CustomButton = {
        let button = CustomButton(icon: UIImage(named: "notifications"), name: "Уведомления")
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        return button
    }()
        
    private let settingsButton: CustomButton = {
        let button = CustomButton(icon: UIImage(named: "settings"), name: "Настройки профиля")
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
        
    private let shareButton: CustomButton = {
        let button = CustomButton(icon: UIImage(named: "share"), name: "Поделиться приложением")
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
        
    private let logoutButton: CustomButton = {
        let button = CustomButton(icon: UIImage(named: "logout"), name: "Выйти из аккаунта")
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        fetchUserInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserInfo()
    }
    
    private func setupUI(){
        view.addSubview(profileImageView)
        view.addSubview(fullNameLabel)
        view.addSubview(editButton)
        view.addSubview(notificationButton)
        view.addSubview(settingsButton)
        view.addSubview(shareButton)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints(){
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(48)
        }
        
        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.centerY.equalTo(profileImageView)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(fullNameLabel.snp.trailing).offset(10)
            make.centerY.equalTo(profileImageView)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(80)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
                
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(notificationButton.snp.bottom).offset(10)
            make.leading.trailing.height.equalTo(notificationButton)
        }
                
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(settingsButton.snp.bottom).offset(80)
            make.leading.trailing.height.equalTo(notificationButton)
        }
                
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(10)
            make.leading.trailing.height.equalTo(notificationButton)
        }
    }
    
    
    @objc private func editButtonTapped(){
        
    }
    
    @objc private func notificationButtonTapped(){
        let notificationViewController = NotificationsViewController()
        navigationController?.pushViewController(notificationViewController, animated: true)
    }

    @objc private func settingsButtonTapped(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        let changePhotoAction = UIAlertAction(title: "Изменить фото", style: .default) { _ in
            self.showImagePicker()
        }
        alertController.addAction(changePhotoAction)
                
        let deleteAccountAction = UIAlertAction(title: "Удалить аккаунт", style: .destructive) { [weak self] _ in
            guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
                return
            }
            
            self?.networkManager.deleteUserAccount(accessToken: accessToken) { result in
                switch result {
                case .success:
                    UserDefaults.standard.removeObject(forKey: "AccessToken")
                    UserDefaults.standard.removeObject(forKey: "RefreshToken")
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            
                    DispatchQueue.main.async {
                        let signInViewController = SignInViewController()
                        self?.navigationController?.pushViewController(signInViewController, animated: true)
                    }
                case .failure(let error):
                    print("Failed to delete account: \(error)")
                }
            }
        }
        deleteAccountAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(deleteAccountAction)
                
        let changePasswordAction = UIAlertAction(title: "Изменить пароль", style: .default) { _ in
            let changePasswordVC = ChangePasswordViewController()
            self.navigationController?.pushViewController(changePasswordVC, animated: true)
        }
        alertController.addAction(changePasswordAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
                
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                self.uploadImage(image)
            }
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data.")
            return
        }
        
        networkManager.uploadUserImage(accessToken: accessToken, imageData: imageData) { [weak self] result in
            switch result {
            case .success(let imageURLString):
                DispatchQueue.main.async {
                    if let imageURL = URL(string: imageURLString) {
                        URLSession.shared.dataTask(with: imageURL) { data, _, error in
                            if let error = error {
                                print("Failed to download image: \(error)")
                                return
                            }
                            if let data = data, let image = UIImage(data: data) {
                                self?.profileImageView.image = image
                            } else {
                                print("Failed to create image from data")
                            }
                        }.resume()
                    } else {
                        print("Invalid image URL")
                    }
                }
            case .failure(let error):
                print("Failed to upload image: \(error)")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func shareButtonTapped(){
        // Handle share button tap
    }
    
    @objc private func logoutButtonTapped(){
        let alertController = UIAlertController(title: "Выход", message: "Выйти из аккаунта?", preferredStyle: .alert)
                
        let logoutAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        alertController.addAction(logoutAction)
                
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
                
        present(alertController, animated: true, completion: nil)
    }
    
    private func performLogout() {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken"), let refreshToken = UserDefaults.standard.string(forKey: "RefreshToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
                
        networkManager.logoutUser(accessToken: accessToken, refreshToken: refreshToken) { [weak self] result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "AccessToken")
                UserDefaults.standard.removeObject(forKey: "RefreshToken")
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        
                DispatchQueue.main.async {
                    let signInViewController = SignInViewController()
                    self?.navigationController?.pushViewController(signInViewController, animated: true)
                }
            case .failure(let error):
                print("Failed to logout: \(error)")
            }
        }
    }
    
    private func updateUI(){
        profileImageView.image = UIImage(named: user?.image ?? "avatar")
        if let firstName = user?.first_name {
            fullNameLabel.text = "\(firstName)"
        } else {
        }
    }
    
    private func fetchUserInfo() {
        guard let accessToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Access token not found in UserDefaults.")
            return
        }
        networkManager.getUserInfo(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.user = user
                    self?.updateUI()
                }
            case .failure(let error):
                print("Failed to fetch user information: \(error)")
            }
        }
    }

}
