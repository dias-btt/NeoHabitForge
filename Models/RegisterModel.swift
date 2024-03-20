//
//  RegisterModel.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 06.03.2024.
//

import Foundation

struct RegisterModel: Encodable {
    let first_name: String
    let phone: String
    let password: String
}
