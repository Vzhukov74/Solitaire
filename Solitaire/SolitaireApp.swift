//
//  SolitaireApp.swift
//  Solitaire
//
//  Created by v.s.zhukov on 19.10.2021.
//

import SwiftUI

@main
struct SolitaireApp: App {
    var body: some Scene {
        WindowGroup {
            GameTableView(viewModel: GameTableViewModel(with: Game()))
            //MainView()
            //GameView(game: Game())
        }
    }
}
