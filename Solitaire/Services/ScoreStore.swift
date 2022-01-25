//
//  ScoreStore.swift
//  Solitaire
//
//  Created by v.s.zhukov on 25.01.2022.
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
