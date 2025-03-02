//
//  SolitaireState.swift
//  card game
//
//  Created by Vladislav Zhukov on 01.03.2025.
//

struct SolitaireState: Codable, Equatable {
    var cards: [CardViewModel] = []
    
    // progress
    var hasMoves: Bool = true
    var hasCancelMove: Bool = false
    var gameOver: Bool = false
    var hasAllCardOpened: Bool = false
        
    var movesNumber: Int = 0
    var pointsNumber: Int = 0
    var timeNumber: Int = 0
    var timeStr: String = "0:00"
    var pointsCoefficient: String = "x 3.0"
}
