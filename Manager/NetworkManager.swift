//
//  NetworkManager.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 05.03.2024.
//
import Alamofire
import Foundation

class NetworkManager {
    func registerUser(firstName: String, phone: String, password: String, completion: @escaping (Result<RegisterUserResponse, ErrorResponse>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/register/"
        
        let parameters: [String: Any] = [
            "first_name": firstName,
            "phone": phone,
            "password": password
        ]
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
        ]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        if let registerUserResponse = try? decoder.decode(RegisterUserResponse.self, from: data) {
                            completion(.success(registerUserResponse))
                        } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                            completion(.failure(errorResponse))
                        } else {
                            completion(.failure(ErrorResponse(error: ErrorDetails(phone: ["Unknown error"]))))
                        }
                    } catch {
                        completion(.failure(ErrorResponse(error: ErrorDetails(phone: ["Decoding error: \(error.localizedDescription)"]))))
                    }
                case .failure(let error):
                    completion(.failure(ErrorResponse(error: ErrorDetails(phone: ["Network request failed: \(error.localizedDescription)"]))))
                }
            }
    }
    
    func loginUser(phone: String, password: String, completion: @escaping (Result<LoginResponse, ErrorResponse>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/login/"
        
        let parameters: [String: Any] = [
            "phone": phone,
            "password": password
        ]
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json",
        ]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                        completion(.success(loginResponse))
                    } catch {
                        completion(.failure(ErrorResponse(error: ErrorDetails(phone: ["Decoding error: \(error.localizedDescription)"]))))
                    }
                case .failure(let error):
                    completion(.failure(ErrorResponse(error: ErrorDetails(phone: ["Network request failed: \(error.localizedDescription)"]))))
                }
            }
    }
    
    func verifyOTP(userId: Int, code: String, completion: @escaping (Result<OTPResponse, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/send-code/\(userId)/"
        
        let parameters: [String: Any] = [
            "code": code
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
        ]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                print(response)
                switch response.result {
                case .success(let data):
                    do {
                        guard let data = data else {
                            throw AFError.responseValidationFailed(reason: .dataFileNil)
                        }
                        let decoder = JSONDecoder()
                        let otpResponse = try decoder.decode(OTPResponse.self, from: data)
                        completion(.success(otpResponse))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getUserInfo(accessToken: String, completion: @escaping (Result<UserMe, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/me/"
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(urlString, method: .get, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let userInfo = try decoder.decode(UserMe.self, from: data)
                        completion(.success(userInfo))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getHabitArticleList(accessToken: String, completion: @escaping (Result<[HabitArticleList], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/article/list/"
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(urlString, method: .get, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let habitArticleList = try decoder.decode([HabitArticleList].self, from: data)
                        completion(.success(habitArticleList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func logoutUser(accessToken: String, refreshToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/logout/"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: [String: Any] = [
            "refresh_token": refreshToken
        ]
        
        AF.request(urlString, method: .post, parameters: parameters, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func uploadUserImage(accessToken: String, imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/image/"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
        }, to: urlString, method: .patch, headers: headers)
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                if let imageURLString = String(data: data, encoding: .utf8) {
                    print("Success - \(imageURLString)")
                    completion(.success(imageURLString))
                } else {
                    completion(.failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    func changePassword(accessToken: String, oldPassword: String, newPassword: String, confirmPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let urlString = "https://neobook.online/app-track/users/change-password/"
            
            let parameters: [String: Any] = [
                "old_password": oldPassword,
                "password": newPassword,
                "confirm_password": confirmPassword
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)",
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
            
            AF.request(urlString, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        }
    
    func resetPassword(newPassword: String, confirmPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/change-password/"
        
        let parameters: [String: Any] = [
            "password": newPassword,
            "confirm_password": confirmPassword
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        AF.request(urlString, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func deleteUserAccount(accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/users/delete/"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        AF.request(urlString, method: .delete, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func fetchArticleContent(articleID: Int, completion: @escaping (Result<ArticleDetail, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/article/detail/\(articleID)/"
        
        AF.request(urlString, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let articleDetail = try decoder.decode(ArticleDetail.self, from: data)
                        completion(.success(articleDetail))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchHabitList(accessToken: String, date: String, completion: @escaping (Result<[HabitList], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/list/?days_name=\(date)"
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(urlString, method: .get, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let habitList = try decoder.decode([HabitList].self, from: data)
                        completion(.success(habitList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchExistingHabitCategoryList(completion: @escaping (Result<[ExistingHabit], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/category/list/"
        
        AF.request(urlString, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let existingHabitList = try decoder.decode([ExistingHabit].self, from: data)
                        completion(.success(existingHabitList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchExistingHabitList(accessToken: String, categoryName: String, completion: @escaping (Result<[ExistingHabitsList], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/existing-habit/list/?category_name=\(categoryName)"
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        AF.request(urlString, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let existingHabitList = try decoder.decode([ExistingHabitsList].self, from: data)
                        completion(.success(existingHabitList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
        
    func createHabit(accessToken: String, habitName: String, days: [Int], customTime: String, goal: String, deadline: Int, reminder: Bool, iconImage: Int, color: Int, completion: @escaping (Result<HabitCreateResponse, Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/create/"
        
        let parameters: [String: Any] = [
            "name": habitName,
            "days": days,
            "goal": goal,
            "deadline": deadline,
            "reminder": reminder,
            "icon_image": iconImage,
            "color": color
        ]
        
        print("Parameters are \(parameters)")
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)",
        ]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let habitCreate = try decoder.decode(HabitCreateResponse.self, from: data)
                        completion(.success(habitCreate))
                    } catch {
                        print("Failure decoding")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func createExistingHabit(accessToken: String, habitID: Int, completion: @escaping (Error?) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/create/existing-habit/\(habitID)/"

        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)",
        ]
        
        AF.request(urlString, method: .post, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                switch response.result {
                case .success:
                    print("Existing habit created successfully")
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
    }

    private var lastTokenRefreshDate: Date?
    private let tokenRefreshInterval: TimeInterval = 3600

    func refreshAccessTokenIfNeeded(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "RefreshToken") else {
            return
        }
        
        if let lastRefreshData = UserDefaults.standard.data(forKey: "LastTokenRefreshDate") {
            let decoder = JSONDecoder()
            if let lastRefreshDate = try? decoder.decode(Date.self, from: lastRefreshData) {
                if Date().timeIntervalSince(lastRefreshDate) < tokenRefreshInterval {
                    print("Token already refreshed")
                    return
                }
            }
        }
        let urlString = "https://neobook.online/app-track/users/login/refresh/"
        let parameters: [String: Any] = [
            "refresh": refreshToken
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
        ]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let refreshResponse = try decoder.decode(RefreshResponse.self, from: data)

                        UserDefaults.standard.set(refreshResponse.access, forKey: "AccessToken")
                        UserDefaults.standard.set(Date(), forKey: "LastTokenRefreshDate")
                        self.lastTokenRefreshDate = Date()
                        completion(.success(refreshResponse.access))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func habitComplete(accessToken: String, habitID: Int, completion: @escaping (Error?) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/\(habitID)/complete/"

        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)",
        ]
        
        AF.request(urlString, method: .post, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                switch response.result {
                case .success:
                    print("Habit completed")
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
    }
    
    func fetchDeadlineList(completion: @escaping (Result<[Deadline], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/deadline/list/"
        
        AF.request(urlString, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let deadlineList = try decoder.decode([Deadline].self, from: data)
                        completion(.success(deadlineList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchIconList(completion: @escaping (Result<[Icon], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/icon-image/list/"
        
        AF.request(urlString, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let iconsList = try decoder.decode([Icon].self, from: data)
                        completion(.success(iconsList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchColorList(completion: @escaping (Result<[Color], Error>) -> Void) {
        let urlString = "https://neobook.online/app-track/habit/color/list/"
        
        AF.request(urlString, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let colorsList = try decoder.decode([Color].self, from: data)
                        completion(.success(colorsList))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
