//
//  MainViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var hasPausedGame: Bool = false
    @Published var presentSettingsScreen: Bool = false
        
    let gameStore: IGamePersistentStore
    let scoreStore: ScoreStore
    
    init(gameStore: IGamePersistentStore, scoreStore: ScoreStore) {
        self.gameStore = gameStore
        self.scoreStore = scoreStore
        
        checkForSavedGame()
    }

    func newGame() {
        gameStore.reset()
    }
    
    func checkForSavedGame() {
        hasPausedGame = gameStore.hasSavedGame
    }
}
