//
//  ContentView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 19.10.2021.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        GameTableView(viewModel: GameTableViewModel(with: Game()))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("0")
    }
}
