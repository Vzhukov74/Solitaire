//
//  SolitaireApp.swift
//  Solitaire
//
//  Created by v.s.zhukov on 19.10.2021.
//

import SwiftUI

@main
struct SolitaireApp: App {
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
