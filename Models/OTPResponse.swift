//
//  OTPResponse.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 11.03.2024.
//

import Foundation

struct OTPResponse: Codable {
    let refresh: String
    let access: String
}
