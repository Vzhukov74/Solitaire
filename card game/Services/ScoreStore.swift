//
//  ScoreStore.swift
//  card game
//
//  Created by Владислав Жуков on 11.08.2024.
//

import Foundation

final class ScoreStore {
    private let key = "com.solitaire.score.store.key"
        
    func save(_ score: Int) {
        UserDefaults.standard.set(score, forKey: key)
    }
    
    func restore() -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
}
