//
//  GameStore.swift
//  Solitaire
//
//  Created by v.s.zhukov on 25.01.2022.
//

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
