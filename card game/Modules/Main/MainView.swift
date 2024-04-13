//
//  MainView.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            Color("mainViewBg")
                .ignoresSafeArea()
            
            NavigationLink(destination: GameView(), isActive: $viewModel.hasGame) {
                EmptyView()
            }
                .navigationTitle("")
            
            VStack {
                LogoView()
                    .padding()
            
                Text("game name")
                    .font(Font.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("primary"))
                Text("🏆 ")
                    .font(Font.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(Color("primary"))
                
                Spacer(minLength: 0)
                
                VStack(spacing: 16) {
                    if viewModel.hasPausedGame {
                        Button(action: viewModel.resumeGame) {
                            Text("continue")
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
                        Text("new game")
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel(gameStore: GameStore(), scoreStore: ScoreStore()))
    }
}

struct LogoView: View {
    @State private var cardRotationAngle: Double = 0
    @State private var cardScale: Double = 0.7
    
    private var width: Double { 300 * 0.5 }
    private var height: Double { 1.5 * width }
    
    var body: some View {
            ZStack(alignment: .center) {
                Image("A♦")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .rotationEffect(.degrees(-1 * cardRotationAngle ), anchor: .bottom)
                    .scaleEffect(cardScale)
                
                Image("A♥")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .scaleEffect(cardScale)
                
                Image("A♠")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .rotationEffect(.degrees(cardRotationAngle), anchor: .bottom)
                    .scaleEffect(cardScale)
                
                Image("A♣")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: 1.5 * width)
                    .rotationEffect(.degrees(2 * cardRotationAngle), anchor: .bottom)
                    .scaleEffect(cardScale)
            }
            .rotationEffect(.degrees(-4), anchor: .bottom)
            .onAppear {
                withAnimation {
                    cardRotationAngle = 12
                    cardScale = 1
                }
            }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}

struct GameView: View {
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 0, geo.size.height > 0 {
                GameTableView(vm: GameTableViewModel(with: Game(), size: geo.size))
            } else {
                EmptyView()
            }

        }
            .navigationTitle("0")
    }
}
