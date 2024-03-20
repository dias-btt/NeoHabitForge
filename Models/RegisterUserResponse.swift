//
//  RegisterUserResponse.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 05.03.2024.
//

import Foundation

struct Message: Codable {
    let id: Int
    let first_name: String
    let phone: String
    let message: String
}

struct RegisterUserResponse: Codable {
    let message: Message
}
