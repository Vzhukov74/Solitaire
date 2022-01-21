//
//  MainView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 20.01.2022.
//

import SwiftUI

struct MainView: View {
    
    
    var body: some View {
        ZStack {
            Color("mainViewBg").ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 0)
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 400)
                
                Text("game name")
                    .foregroundColor(Color("primary"))
                //Text("")
                
                VStack(spacing: 16) {
                    Button(action: {}) {
                        Text("Продолжить игру")
                    }
                    .frame(height: 46)
                    .padding(.horizontal, 32)
                    .background(Color.green)
                    .clipShape(Capsule())
                    
                    Button(action: {}) {
                        Text("Новая Игра")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 32)
                    .frame(height: 46)
                    .background(Color.white)
                    .clipShape(Capsule())
                    //.shadow(color: Color.black, radius: 0, x: 3, y: 3)
                }
            }
                .frame(maxWidth: .infinity)
        }
     
    }
}

class AppState: ObservableObject {
    //@Published var game: Game?
    
     
}
