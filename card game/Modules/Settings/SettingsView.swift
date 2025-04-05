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
    
    private let cRotation: Double = 12
    private let stackRotation: Double = -4
    
    var body: some View {
        VStack(spacing: 8) {
            headerView
            ScrollView(showsIndicators: false) {
                #if os(iOS)
                soundAndVibrationView
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                #endif
                cardBacksView
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                cardFrontsView
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                tableBackgroundView
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
                    .font(.title)
                    .foregroundStyle(Color.black)
                Spacer(minLength: 0)
                Color.clear
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("accent"))
                    }
                    .onTapGesture { withAnimation { isPresenting = false } }
            }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .padding(.top, 16)
        }
    }
    
    private var soundAndVibrationView: some View {
        HStack(spacing: 16) {
            Button(
                action: { vm.toggleSound() },
                label: {
                    VStack {
                        Text(String(localized: "Звук") + " " + String(localized: vm.isSoundOn ? "вкл" : "выкл"))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Image(systemName: vm.isSoundOn ? "speaker" : "speaker.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 22)
                            .foregroundColor(.black)
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(Color.white.opacity(0.2))
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
                        Text(String(localized: "Вибрация") + " " + String(localized: vm.isVibrationOn ? "вкл" : "выкл"))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Image(vm.isVibrationOn ? "vibration_on" : "vibration_off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 22)
                            .foregroundColor(.black)
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(Color.white.opacity(0.2))
                            .shadow(radius: 2, x: 0.5, y: 1)
                    }
                }
            )
                .frame(maxWidth: .infinity)
            #endif
        }
    }
    
    private var cardBacksView: some View {
        VStack(spacing: 16) {
            Text("Рубашка")
                .font(.title3)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(vm.backs.indices, id: \.self) { index in
                        vm.backs[index].1
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(vm.backs[index].0 == vm.selectedBackId ? 0.78 : 1)
                            .background {
                                vm.backs[index].0 == vm.selectedBackId ?
                                Color.black.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 8)) : Color.clear.clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .onTapGesture {
                                withAnimation { vm.select(cardBackId: vm.backs[index].0) }
                            }
                    }
                }
            }
                .padding(8)
        }
    }
    
    private var cardFrontsView: some View {
        VStack(spacing: 16) {
            Text("Обложка")
                .font(.title3)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                cardFront(for: vm.fronts[0].1, id: vm.fronts[0].0)
                cardFront(for: vm.fronts[1].1, id: vm.fronts[1].0)
            }
                .padding(8)
        }
    }
    
    private func cardFront(for cards: [Image], id: String) -> some View {
        Color.clear
            .background {
                vm.selectedFrontId == id ?
                Color.black.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 8)) : Color.clear.clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .overlay {
                ZStack(alignment: .center) {
                    cards[0]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 100)
                        .rotationEffect(.degrees(-1 * cRotation), anchor: .bottom)
                    
                    cards[1]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 100)
                    
                    cards[2]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 100)
                        .rotationEffect(.degrees(cRotation), anchor: .bottom)
                    
                    cards[3]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 100)
                        .rotationEffect(.degrees(2 * cRotation), anchor: .bottom)
                }
                .rotationEffect(.degrees(stackRotation), anchor: .bottom)
                .frame(width: 130, height: 120)
                .scaleEffect(vm.selectedFrontId == id ? 0.78 : 1)
            }
            .onTapGesture {
                withAnimation { vm.select(cardFrontId: id) }
            }
    }
    
    private var tableBackgroundView: some View {
        VStack(spacing: 16) {
            Text("Цвет стола")
                .font(.title3)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    tableBackgroundColorView(id: vm.tableColors[0])
                    tableBackgroundColorView(id: vm.tableColors[1])
                }
                HStack(spacing: 8) {
                    tableBackgroundColorView(id: vm.tableColors[2])
                    tableBackgroundColorView(id: vm.tableColors[3])
                }
            }
        }
    }
    
    private func tableBackgroundColorView(id: String) -> some View {
        Color.clear
            .background {
                vm.selectedTableColorsId == id ?
                Color.black.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 8)) : Color.clear.clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .overlay {
                Color(id)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(height: 100)
                    .scaleEffect(vm.selectedTableColorsId == id ? 0.78 : 1)
            }
            .onTapGesture {
                withAnimation { vm.select(tableColorsId: id) }
            }
    }
}
