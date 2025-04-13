//
//  CardViewModel.swift
//  card game
//
//  Created by Vladislav Zhukov on 01.03.2025.
//

import Foundation

struct CardViewModel: Hashable, Codable {
    let card: Card
    
    var isOpen: Bool
    var column: Int
    var row: Int
    
    var position: CGPoint
    var zIndex: Int
    var error: Int
}
