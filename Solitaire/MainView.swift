//
//  MainView.swift
//  Solitaire
//
//  Created by v.s.zhukov on 20.01.2022.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            Color("mainViewBg")
                .ignoresSafeArea()
            
            VStack {
                LogoView()
                    .padding()
            
                Text("game name")
                    .font(Font.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("primary"))
                Text("score 28600")
                    .font(Font.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(Color("primary"))
                
                Spacer(minLength: 0)
                
                VStack(spacing: 16) {
                    if viewModel.hasPausedGame {
                        Button(action: viewModel.resumeGame) {
                            Text("Продолжить игру")
                                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color.white)
                        }
                        .frame(height: 46)
                        .padding(.horizontal, 32)
                        .background(Color("accent"))
                        .clipShape(Capsule())
                    }
                    
                    Button(action: viewModel.newGame) {
                        Text("Новая Игра")
                            .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("accent"))
                    }
                    .padding(.horizontal, 32)
                    .frame(height: 46)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
            }
                .padding(.vertical, 32)
        }
    }
}

final class MainViewModel: ObservableObject {
    @Published var hasPausedGame: Bool = false
    @Published var game: Game?
    
    func newGame() {
        game = Game()
    }
    
    func resumeGame() {
        game = Game()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}

class AppState: ObservableObject {
    //@Published var game: Game?
}

