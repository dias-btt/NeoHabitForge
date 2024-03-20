//
//  AddHabitsModels.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 17.03.2024.
//

import Foundation

struct Icon: Codable, Equatable {
    let id: Int
    let image: String
}

struct Deadline: Codable {
    let id: Int
    let name: String
    let time: String?
}

struct Color: Codable {
    let id: Int
    let name: String
}
