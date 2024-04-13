//
//  card_gameApp.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

@main
struct card_gameApp: App {
    @Environment(\.scenePhase) var scenePhase
        
    private let gameStore = GameStore()
    private let scoreStore = ScoreStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView(viewModel: MainViewModel(gameStore: gameStore, scoreStore: scoreStore))
            }
                .accentColor(Color("primary"))
        }
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .active: break
                case .background: break
                case .inactive:
                    gameStore.save()
                    //scoreStore.save(appState.score)
                @unknown default: break
                }
            }
    }
}

import Foundation

final class GameStore {
    private let persistentStore: GamePersistentStoreProtocol
    
    var game: Game?
    var hasSavedGame: Bool { game != nil }
    
    init(persistentStore: GamePersistentStoreProtocol = GamePersistentStore()) {
        self.persistentStore = persistentStore
        self.game = persistentStore.restore()
    }
    
    func save() {
        guard let game = game else { return }
        persistentStore.save(game)
    }
    
    func newGame() {
        game = Game()
    }
}

protocol GamePersistentStoreProtocol: AnyObject {
    func save(_ game: Game)
    func restore() -> Game?
}

final class GamePersistentStore: GamePersistentStoreProtocol {
    private let key = "com.solitaire.game.store.key"
    
    func save(_ game: Game) {
        guard let data = try? JSONEncoder().encode(game) else { return }
        
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func restore() -> Game? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        guard let game = try? JSONDecoder().decode(Game.self, from: data) else { return nil }
        
        return game
    }
}

final class ScoreStore {
    private let key = "com.solitaire.score.store.key"
        
    func save(_ score: Int) {
        UserDefaults.standard.set(score, forKey: key)
    }
    
    func restore() -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
}
