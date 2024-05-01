//
//  MainView.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm: MainViewModel
    
    var body: some View {
        ZStack {
            Color("mainViewBg")
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button(
                        action: { vm.presentSettingsScreen = true },
                        label: {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .padding(9)
                        }
                    )
                        .frame(width: 44, height: 44)
                }
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                
                MainViewCardsLogo()
                    .padding()
            
                Text("game name")
                    .font(Font.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("primary"))
                Text("🏆 ")
                    .font(Font.system(size: 30, weight: .regular, design: .rounded))
                    .foregroundColor(Color("primary"))
                
                Spacer(minLength: 0)
                
                VStack(spacing: 16) {
                    if vm.hasPausedGame {
                        Button(action: vm.resumeGame) {
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
            
                    Button(action: vm.newGame) {
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
            
            if vm.presentGameScreen {
                let game: Game? = vm.presentFromSaved && vm.gameStore.game != nil ? vm.gameStore.game! : nil
                GameView(
                    isPresenting: $vm.presentGameScreen,
                    gameStore: vm.gameStore, 
                    feedbackService: AppDI.shared.service(),
                    game: game
                )
            } else if vm.presentSettingsScreen {
                SettingsView(
                    vm: SettingsViewModel(uiSettings: AppDI.shared.service()),
                    isPresenting: $vm.presentSettingsScreen
                )
            }
        }
    }
}
