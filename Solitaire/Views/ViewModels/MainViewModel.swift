//
//  MainViewModel.swift
//  Solitaire
//
//  Created by v.s.zhukov on 25.01.2022.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var hasPausedGame: Bool = false
    @Published var hasGame: Bool = false
        
    let gameStore: GameStore
    let scoreStore: ScoreStore

    init(gameStore: GameStore, scoreStore: ScoreStore) {
        self.gameStore = gameStore
        self.scoreStore = scoreStore
    }

    func newGame() {
        gameStore.newGame()
        
        guard gameStore.game != nil else { return }
        hasGame = true
    }

    func resumeGame() {
        guard gameStore.game != nil else { return }
        hasGame = true
    }
    
    func checkForSavedGame() {
        hasPausedGame = gameStore.hasSavedGame
    }
}
