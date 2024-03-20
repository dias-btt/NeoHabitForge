//
//  HabitArticleList.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import Foundation
import UIKit

struct HabitArticleList: Decodable {
    let id: Int
    let title: String
    let image: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
    }
}

