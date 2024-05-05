//
//  GameStore.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import Foundation

protocol IGamePersistentStore: AnyObject {
    var game: Game? { get }
    var hasSavedGame: Bool { get }
    
    func save(_ game: Game)
    func reset()
}

final class GamePersistentStore: IGamePersistentStore {
    private let key = "com.solitaire.game.store.key"
    
    var game: Game? { restore() }
    var hasSavedGame: Bool { game != nil }
    
    func save(_ game: Game) {
        guard let data = try? JSONEncoder().encode(game) else { return }
        
        UserDefaults.standard.set(data, forKey: key)
    }
        
    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    private func restore() -> Game? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        guard let game = try? JSONDecoder().decode(Game.self, from: data) else { return nil }
        
        return game
    }
}
