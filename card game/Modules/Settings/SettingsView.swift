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
                    action: { isPresenting = false },
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
                    Capsule().foregroundColor(.cyan)
                }
                .padding(.top, 24)
                .padding(.horizontal, 8)
        }
    }
}
