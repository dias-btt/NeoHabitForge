//
//  ErrorResponse.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 06.03.2024.
//

import Foundation

struct ErrorResponse: Codable, Error {
    let error: ErrorDetails
}

struct ErrorDetails: Codable {
    let phone: [String]
}
