//
//  LeadersSheetView.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 24.04.2025.
//

import SwiftUI

struct LeadersSheetView: View {
    
    let leaders: [LeadersSheet.Leaders]
    
    var body: some View {
        VStack {
            headerView
                .padding(.horizontal, 16)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(leaders.indices, id: \.self) { index in
                        leaderView(
                            leader: leaders[index],
                            isOdd: index % 2 == 0,
                            isPlayer: leaders[index].id == ""
                        )
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Результаты недели")
                .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(16)
            HStack {
                Text("Место")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Имя")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Очки")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
                .font(Font.system(size: 20, weight: .regular, design: .rounded))
        }
            .foregroundColor(.white)
            .padding(.horizontal,16)
    }
    
    private func leaderView(leader: LeadersSheet.Leaders, isOdd: Bool, isPlayer: Bool) -> some View {
        HStack {
            HStack(alignment: .center, spacing: 8) {
                if leader.place <= 3 {
                    Image(.laurelwreath)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(leader.place.placeColor)
                } else {
                    Text("\(leader.place)")
                }
            }
                .frame(maxWidth: .infinity, alignment: .center)
            Text(leader.name)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("\(leader.points)")
                .frame(maxWidth: .infinity, alignment: .center)
        }
            .frame(maxWidth: .infinity, alignment: .center)
            .font(Font.system(size: 18, weight: .regular, design: .rounded))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(isOdd ? Color.clear : Color(.accent).opacity(0.6))
            }
            .padding(.horizontal, 16)
    }
}

private extension Int {
    var placeColor: Color {
        if self > 0, self <= 3 {
            if self == 1 {
                return Color(.gold)
            } else if self == 2 {
                return Color(.silver)
            } else {
                return Color(.bronze)
            }
        } else {
            return .clear
        }
    }
}
