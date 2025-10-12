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
//            NavigationLink(value: vm.challengeOfDayForPlay) {
//                TableView(
//                    gameStore: AppDI.shared.service(),
//                    feedbackService: AppDI.shared.service(),
//                    cardUIServices: AppDI.shared.service(),
//                    game: nil,
//                    challengeOfDay: vm.challengeOfDayForPlay!
//                )
//                    .toolbar(.hidden)
//            }
                        
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack {
                    gearSettingsView
                    
                    MainViewCardsLogo()
                        .padding()
                        .padding(.vertical, 24)
                        .padding(.bottom, 24)

                    Spacer(minLength: 0)
                    
                    buttonsView
                }
                    .padding(.vertical, 16)
                
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
            .sheet(isPresented: $vm.showTournamentOnboarding) {
                SimpleAnimatedPageView(
                    onFinish: {
                        vm.didShowTournamentOnboarding()
                        vm.challengeOfDayForPlay = vm.challengeOfDay
                    },
                    onCancel: {
                        vm.didShowTournamentOnboarding()
                    }
                )
            }
        }
    }
    
    private var gearSettingsView: some View {
        HStack(spacing: 16) {
            Spacer()
            Color.clear
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "trophy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("accent"))
                        .padding(9)
                }
                .onTapGesture { withAnimation { vm.presentSettingsScreen = true } }
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
        VStack(alignment: .center, spacing: 8) {
            if vm.challengeOfDay != nil {
                NavigationLink(
                    destination: {
                        TableView(
                            gameStore: AppDI.shared.service(),
                            feedbackService: AppDI.shared.service(),
                            cardUIServices: AppDI.shared.service(),
                            game: nil,
                            challengeOfDay: vm.challengeOfDay!
                        )
                            .toolbar(.hidden)
                    },
                    label: {
                        HStack(alignment: .center, spacing: 8) {
                            Image(.laurelwreath)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.white)
                            Text("Рейтинг Дня")
                                .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                        }
                            .frame(height: 46)
                            .padding(.horizontal, 36)
                            .background {
                                CustomButtonBgShape().foregroundColor(Color("accent"))
                            }
                            .frame(maxWidth: 320)
                    }
                )
                .padding(.bottom, 11)
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
                            .foregroundColor(Color("accent"))
                            .padding(.horizontal, 32)
                            .frame(height: 46)
                            .frame(maxWidth: 320)
                    }
                )
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
    }
}
