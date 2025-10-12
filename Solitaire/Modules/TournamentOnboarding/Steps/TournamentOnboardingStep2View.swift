//
//  TournamentOnboardingStep2View.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 24.09.2025.
//

import SwiftUI

struct TournamentOnboardingStep2ViewStyled: View {
    var body: some View {
        VStack(spacing: 0) {
            TournamentHeaderView(
                title: "Рейтинг Дня",
                subtitle: "Обновляется ежедневно",
                icon: "calendar.circle.fill"
            )
                .padding(.top, 40)
            
            Spacer()
            
            PlayersRankingView()
            
            Spacer()
            
            TournamentDetailView(
                title: "Каждая успешная партия приносит очки",
                subtitle: "Ваша задача — занять как можно более высокое место в ежедневном рейтинге до конца дня"
            )
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
}

private struct RankingEntry: Identifiable {
    let id = UUID()
    let place: Int
    let name: String
    let score: Int
    let isCurrentUser: Bool
}

private struct PlayersRankingView: View {
    
    private let rankingData = [
        RankingEntry(place: 1, name: "ВЫ", score: 2500, isCurrentUser: true),
        RankingEntry(place: 2, name: "Anna", score: 2450, isCurrentUser: false),
        RankingEntry(place: 3, name: "Alex", score: 2300, isCurrentUser: false),
        RankingEntry(place: 4, name: "Mike", score: 2250, isCurrentUser: false),
        RankingEntry(place: 5, name: "Sarah", score: 2200, isCurrentUser: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок таблицы
            HStack {
                Text("Место")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Игрок")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Очки")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            
            // Строки рейтинга
            ForEach(rankingData) { entry in
                RankingRowStyled(entry: entry)
                
                if entry.place < rankingData.count {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

private struct RankingRowStyled: View {
    let entry: RankingEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // Место с иконкой
            HStack(spacing: 8) {
                if entry.place <= 3 {
                    Image(.laurelwreath)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(entry.place.placeColor)
                }
                
                Text("\(entry.place)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(entry.place <= 3 ? .primary : .secondary)
                    .frame(width: 20)
            }
            .frame(width: 60, alignment: .leading)
            
            HStack(spacing: 6) {
                if entry.isCurrentUser {
                    Text("ВЫ")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.accent))
                } else {
                    Text(entry.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()

            Text("\(entry.score)")
                .font(.system(size: 16, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(entry.isCurrentUser ? Color(.accent).opacity(0.15) : Color.clear)
        .cornerRadius(8)
        .padding(.horizontal, 4)
    }
}
