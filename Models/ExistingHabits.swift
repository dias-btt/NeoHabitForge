//
//  ExistingHabits.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 18.03.2024.
//

import Foundation

struct ExistingHabit: Codable, Equatable{
    let id: Int
    let name: String
    let image: String
}

struct ExistingHabitsList: Codable, Equatable {
    let id: Int
    let name: String
    let icon_image: Icon?
}
