//
//  SolitaireState.swift
//  card game
//
//  Created by Vladislav Zhukov on 01.03.2025.
//

struct SolitaireState: Codable, Equatable {
    var cards: [CardViewModel] = []

    var movesNumber: Int = 0
    var pointsNumber: Int = 0
    var timeNumber: Int = 0
}
