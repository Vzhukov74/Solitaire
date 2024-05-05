//
//  SettingsView.swift
//  card game
//
//  Created by Владислав Жуков on 30.04.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var vm: SettingsViewModel
    @Binding var isPresenting: Bool
    
    var body: some View {
        
        VStack(spacing: 8) {
            headerView
            ScrollView(showsIndicators: false) {
                soundAndVibrationView
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            }
        }
            .background {
                Color.white.ignoresSafeArea()
            }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 16) {
                Text("Настройки")
                    .font(.title2)
                Spacer(minLength: 0)
                Button(
                    action: { withAnimation { isPresenting = false } },
                    label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                )
            }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background {
                    Capsule()
                        .foregroundColor(.cyan)
                        .shadow(radius: 2, x: 0.5, y: 1)
                }
                .padding(.top, 24)
                .padding(.horizontal, 8)
        }
    }
    
    private var soundAndVibrationView: some View {
        HStack(spacing: 16) {
            Button(
                action: { vm.toggleSound() },
                label: {
                    VStack {
                        Text("Звук \(vm.isSoundOn ? "вкл" : "выкл")")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Image(systemName: vm.isSoundOn ? "speaker" : "speaker.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 22)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(Color("accent"))
                            .shadow(radius: 2, x: 0.5, y: 1)
                    }
                }
            )
                .frame(maxWidth: .infinity)
            #if os(iOS)
            Button(
                action: { vm.toggleVibration() },
                label: {
                    VStack {
                        Text("Вибрация \(vm.isVibrationOn ? "вкл" : "выкл")")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Image(vm.isVibrationOn ? "vibration_on" : "vibration_off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 22)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(Color("accent"))
                            .shadow(radius: 2, x: 0.5, y: 1)
                    }
                }
            )
                .frame(maxWidth: .infinity)
            #endif
        }
    }
}
