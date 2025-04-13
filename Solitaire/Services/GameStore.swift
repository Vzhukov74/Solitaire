//
//  GameStore.swift
//  card game
//
//  Created by Владислав Жуков on 21.04.2024.
//

import Foundation

protocol IGamePersistentStore: AnyObject {
    var game: SolitaireGame? { get }
    var hasSavedGame: Bool { get }
    
    func save(_ game: SolitaireGame)
    func reset()
}

final class GamePersistentStore: IGamePersistentStore {
    private let key = "com.solitaire.game.store.v2.key"
    
    var game: SolitaireGame? { restore() }
    var hasSavedGame: Bool { game != nil }
    
    func save(_ game: SolitaireGame) {
        guard let data = try? JSONEncoder().encode(game) else { return }
        
        UserDefaults.standard.set(data, forKey: key)
    }
        
    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    private func restore() -> SolitaireGame? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        guard let game = try? JSONDecoder().decode(SolitaireGame.self, from: data) else { return nil }
        
        return game
    }
}
