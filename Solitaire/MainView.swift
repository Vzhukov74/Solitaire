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
            
            Text("game name")
                .foregroundColor(Color("primary"))
            //Text("")
            
            VStack(spacing: 16) {
                Button(action: {}) {
                    Text("Продолжить игру")
                }
                .frame(width: UIScreen.main.bounds.width - 64, height: 46)
                .background(Color.green)
                .clipShape(Capsule())
                
                Button(action: {}) {
                    Text("Новая Игра")
                }
                .frame(width: UIScreen.main.bounds.width - 64, height: 46)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color.black, radius: 0, x: 3, y: 3)
            }
        }
            .padding(.vertical, 48)
            .ignoresSafeArea()
            .background(Color("mainViewBg"))
        
    }
}
