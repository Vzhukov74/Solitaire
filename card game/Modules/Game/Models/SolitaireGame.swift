//
//  SolitaireGame.swift
//  card game
//
//  Created by Vladislav Zhukov on 02.03.2025.
//

struct SolitaireGame: Codable {
    let state: SolitaireState
    let history: [SolitaireState]
}
