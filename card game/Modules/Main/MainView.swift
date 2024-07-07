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
            Color.white
                .ignoresSafeArea()
            VStack {
                gearSettingsView
                
                MainViewCardsLogo()
                    .padding()
                    .padding(.vertical, 24)
                            
                Spacer(minLength: 0)
                
                buttonsView
            }
                .padding(.vertical, 16)
                .onAppear { vm.checkForSavedGame() }
            
            if vm.presentGameScreen {
                let game: Game? = vm.presentFromSaved && vm.gameStore.game != nil ? vm.gameStore.game! : nil
                GameView(
                    isPresenting: $vm.presentGameScreen,
                    gameStore: vm.gameStore, 
                    feedbackService: AppDI.shared.service(),
                    game: game
                )
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            } else if vm.presentSettingsScreen {
                SettingsView(
                    vm: SettingsViewModel(
                        uiSettings: AppDI.shared.service(),
                        feedbackService: AppDI.shared.service(), 
                        cardUIServices: AppDI.shared.service()
                    ),
                    isPresenting: $vm.presentSettingsScreen
                )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
    
    private var gearSettingsView: some View {
        HStack {
            Spacer()
            Button(
                action: { withAnimation { vm.presentSettingsScreen = true } },
                label: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("accent"))
                        .rotationEffect(vm.presentSettingsScreen ? Angle(degrees: -90) : Angle(degrees: 0))
                        .animation(.easeInOut, value: vm.presentSettingsScreen)
                        .padding(9)
                }
            )
                .frame(width: 44, height: 44)
        }
            .frame(height: 44)
            .padding(.horizontal, 16)
    }
    
    private var buttonsView: some View {
        VStack(spacing: 16) {
            if vm.hasPausedGame {
                Button(action: vm.resumeGame) {
                    Text("Продолжить")
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
                Text("Новая игра")
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
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
    }
}
