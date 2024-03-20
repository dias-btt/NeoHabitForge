//
//  HabitCreate.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 14.03.2024.
//

import Foundation

struct HabitCreateRequest: Codable {
    let name: String
    let days: [Int]
    let custom_time: String
    let goal: String
    let deadline: Int
    let reminder: Bool
    let icon_image: Int
    let color: Int
}

struct HabitCreateResponse: Codable, Equatable {
    let id: Int?
    let name: String?
    let days: [Int]?
    let custom_time: [String]?
    let goal: String?
    let deadline: Int?
    let reminder: Bool?
    let icon_image: Int?
    let color: Int?
}

struct HabitList: Codable, Equatable {
    let id: Int
    let name: String
    let icon_image: Int
    var is_completed: Bool
}
