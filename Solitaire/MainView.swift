//
//  MainView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 20.01.2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            
            Spacer(minLength: 0)
            
            Text("Solitaire")
            //Text("")
            
            Button(action: {}) {
                Text("Продолжить игру")
            }.background(Capsule().foregroundColor(Color.gray))
            Button(action: {}) {
                Text("Новая Игра")
            }.background(Capsule().foregroundColor(Color.gray))
        }
            .padding(.vertical, 48)
    }
}
