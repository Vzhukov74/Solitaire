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
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack {
                    gearSettingsView
                    
                    MainViewCardsLogo()
                        .padding()
                        .padding(.vertical, 24)
                        .padding(.bottom, 24)

                    if vm.challengeOfWeek != nil {
                        ChallengeOfWeekView(challenge: vm.challengeOfWeek!)
                            .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 0)
                    
                    buttonsView
                }
                    .padding(.vertical, 16)
                    .onAppear { vm.checkForSavedGame() }
                
                if vm.presentSettingsScreen {
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
            .onAppear { vm.checkForSavedGame() }
        }
    }
    
    private var gearSettingsView: some View {
        HStack {
            Spacer()
            Color.clear
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("accent"))
                        .rotationEffect(vm.presentSettingsScreen ? Angle(degrees: -90) : Angle(degrees: 0))
                        .animation(.easeInOut, value: vm.presentSettingsScreen)
                        .padding(9)
                }
                .onTapGesture { withAnimation { vm.presentSettingsScreen = true } }
        }
            .frame(height: 44)
            .padding(.horizontal, 16)
    }
    
    private var buttonsView: some View {
        VStack(alignment: .center, spacing: 16) {
            if vm.hasPausedGame {
                NavigationLink(
                    destination: {
                        TableView(
                            gameStore: vm.gameStore,
                            feedbackService: AppDI.shared.service(),
                            cardUIServices: AppDI.shared.service(),
                            game: vm.gameStore.game
                        )
                            .toolbar(.hidden)
                    },
                    label: {
                        Text("Продолжить")
                            .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .frame(height: 46)
                            .padding(.horizontal, 36)
                            .background {
                                CustomButtonBgShape().foregroundColor(Color("accent"))
                            }
                            .frame(maxWidth: 320)
                            .padding(.horizontal, 32)
                    }
                )
            }
    
            NavigationLink(
                destination: {
                    TableView(
                        gameStore: vm.gameStore,
                        feedbackService: AppDI.shared.service(),
                        cardUIServices: AppDI.shared.service(),
                        game: nil
                    )
                        .onAppear { vm.newGame() }
                        .toolbar(.hidden)
                },
                label: {
                    Text("Новая игра")
                        .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color("accent"))
                        .padding(.horizontal, 32)
                        .frame(height: 46)
                        .frame(maxWidth: 320)
                }
            )
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
    }
}

struct ChallengeOfWeekView: View {
    
    let challenge: DeckShuffler
    
    var body: some View {
        NavigationLink(
            destination: {
                TableView(
                    gameStore: AppDI.shared.service(),
                    feedbackService: AppDI.shared.service(),
                    cardUIServices: AppDI.shared.service(),
                    game: nil,
                    deck: challenge
                )
                    .toolbar(.hidden)
            },
            label: {
                challengeView
            }
        )
    }
    
    private var challengeView: some View {
        HStack(spacing: 16) {
            Image(.ca1)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 30)
            VStack {
                Text("Раскладка недели")
                    .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.white)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.accentColor)
        }
    }
}
