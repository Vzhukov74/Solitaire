//
//  MainViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    @Published var hasPausedGame: Bool = false
    @Published var presentGameScreen: Bool = false
    @Published var presentSettingsScreen: Bool = false
    
    var presentFromSaved: Bool = false
    
    let gameStore: IGamePersistentStore
    let scoreStore: ScoreStore

    private var cancellable = Set<AnyCancellable>()
    
    init(gameStore: IGamePersistentStore, scoreStore: ScoreStore) {
        self.gameStore = gameStore
        self.scoreStore = scoreStore
        
        hasPausedGame = gameStore.hasSavedGame
        
        $presentGameScreen
            .dropFirst()
            .sink { [weak self] isPresentGameScreen in
                guard !isPresentGameScreen else { return }
                guard let self else { return }
                let flag = gameStore.hasSavedGame
                Task { @MainActor in
                    self.hasPausedGame = flag
                }
            }
            .store(in: &cancellable)
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
