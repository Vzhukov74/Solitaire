//
//  MainViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var hasPausedGame: Bool = false
    @Published var presentGameScreen: Bool = false
    @Published var presentSettingsScreen: Bool = false
    
    var presentFromSaved: Bool = false
    
    let gameStore: GameStore
    let scoreStore: ScoreStore

    init(gameStore: GameStore, scoreStore: ScoreStore) {
        self.gameStore = gameStore
        self.scoreStore = scoreStore
        
        hasPausedGame = gameStore.hasSavedGame
    }

    func newGame() {
        presentFromSaved = false
        withAnimation { presentGameScreen = true }
    }

    func resumeGame() {
        guard gameStore.game != nil else { return }
        presentFromSaved = true
        withAnimation { presentGameScreen = true }
    }
    
    func checkForSavedGame() {
        hasPausedGame = gameStore.hasSavedGame
    }
}
