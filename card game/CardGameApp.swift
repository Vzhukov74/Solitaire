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
            MainView(vm: MainViewModel(gameStore: gameStore, scoreStore: scoreStore))
        }
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .active, .background: break
                case .inactive:
                    gameStore.save()
                    //scoreStore.save(appState.score)
                @unknown default: break
                }
            }
            .defaultSize(width: 582.0, height: 582.0)
    }
}

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
