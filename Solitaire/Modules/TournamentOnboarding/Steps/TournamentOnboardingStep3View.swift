//
//  TournamentOnboardingStep3View.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 24.09.2025.
//

import SwiftUI

struct TournamentOnboardingStep3View: View {

    var body: some View {
        VStack(spacing: 0) {
            TournamentHeaderView(
                title: "Итоги Недели",
                subtitle: nil,
                icon: "trophy.circle.fill"
            )
                .padding(.top, 40)
            
            Spacer()
            
            TournamentWeekResult()
            
            Spacer()
            
            TournamentDetailView(
                title: "Ваши ежедневные результаты суммируются",
                subtitle: "Участвуйте всю неделю, чтобы получить звание Чемпиона недели и уникальные достижения"
            )
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
}

struct TournamentWeekResult: View {
    
    // Прогресс недели
    private let weekProgress = [
        DayProgress(day: "Пн", status: .completed, points: 2450),
        DayProgress(day: "Вт", status: .completed, points: 2520),
        DayProgress(day: "Ср", status: .completed, points: 2380),
        DayProgress(day: "Чт", status: .current, points: 0),
        DayProgress(day: "Пт", status: .upcoming, points: 0),
        DayProgress(day: "Сб", status: .upcoming, points: 0),
        DayProgress(day: "Вс", status: .upcoming, points: 0)
    ]
    
    private func calculateProgressWidth() -> CGFloat {
        let totalWidth = UIScreen.main.bounds.width - 64
        let completedDays = weekProgress.filter { $0.status == .completed }.count
        let totalDays = weekProgress.count
        return totalWidth * CGFloat(completedDays) / CGFloat(totalDays)
    }
    
    var body: some View {
        // Week Progress
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center, spacing: 16) {
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.accent))
                                .frame(height: 6)
                                .frame(width: calculateProgressWidth())
                        }
                        .overlay {
                            weekDotsProgressView
                        }
                    
                    weekTextProgressView
                }
                
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(Color(.accent))
            }
                        
            VStack(alignment: .leading, spacing: 10) {
                LegendItem(color: Color(.accent), text: "заполнено")
                LegendItem(color: .primary, text: "текущий")
                LegendItem(color: Color.gray, text: "предстоит")
            }
        }
        .padding(.horizontal, 32)
    }
    
    private var weekDotsProgressView: some View {
        HStack(alignment: .center) {
            ForEach(weekProgress) { day in
                Circle()
                    .fill(day.status.color)
                    .frame(width: day.status.pointSize, height: day.status.pointSize)
                if day.day != "Вс" {
                    Spacer()
                }
            }
        }
    }
    
    private var weekTextProgressView: some View {
        HStack(alignment: .center) {
            ForEach(weekProgress) { day in
                VStack(spacing: 4) {
                    Text(day.day)
                        .font(.caption)
                        .fontWeight(day.status == .current ? .bold : .medium)
                        .foregroundColor(day.status == .current ? .primary : .secondary)
                    
                    if day.status == .completed && day.points > 0 {
                        Text("\(day.points)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                if day.day != "Вс" {
                    Spacer()
                }
            }
        }
    }
}

struct DayProgress: Identifiable {
    let id = UUID()
    let day: String
    let status: ProgressStatus
    let points: Int
}

enum ProgressStatus {
    case completed    // завершено
    case current      // текущий
    case upcoming     // предстоит
    
    var color: Color {
        switch self {
        case .completed: return Color(.accent)
        case .current: return Color(.accent)
        case .upcoming: return Color.gray
        }
    }
    
    var pointSize: CGFloat {
        switch self {
        case .completed: return 16
        case .current: return 24
        case .upcoming: return 12
        }
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
