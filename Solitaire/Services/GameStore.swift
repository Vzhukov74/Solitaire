//
//  GameStore.swift
//  Solitaire
//
//  Created by v.s.zhukov on 25.01.2022.
//

import Foundation

final class GameStore {
    private let key = "com.solitaire.game.store.key"
    
    var hasSavedGame: Bool { restore() != nil }
    
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
