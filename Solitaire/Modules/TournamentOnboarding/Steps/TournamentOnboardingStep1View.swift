//
//  TournamentOnboardingStep1View.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 24.09.2025.
//

import SwiftUI

struct TournamentOnboardingStep1View: View {    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            TournamentHeaderView(
                title: "Что-то новое, пора соревноваться!",
                subtitle: nil,
                icon: nil
            )
                .padding(.top, 40)
            
            Spacer()
            
            GradientCircle()
                .overlay {
                    PodiumWithTrophyIcon()
                }

            Spacer()
            
            TournamentDetailView(
                title: "Теперь каждый день участвуйте в соревновании",
                subtitle: "Играйте в Косынку как обычно, но зарабатывайте очки и поднимайтесь в рейтинге против других игроков"
            )
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
}

struct PodiumWithTrophyIcon: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 60, height: 55)
                .overlay(
                    Text("2")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .overlay(
                    Text("🥈")
                        .font(Font.system(size: 40))
                        .offset(y: -45)
                )
            Rectangle()
                .fill(Color.gray)
                .frame(width: 60, height: 80)
                .overlay(
                    Text("1")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .overlay(
                    Text("🏆")
                        .font(Font.system(size: 40))
                        .offset(y: -60)
                )
            Rectangle()
                .fill(Color.gray.opacity(0.6))
                .frame(width: 60, height: 40)
                .overlay(
                    Text("3")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .overlay(
                    Text("🥉")
                        .font(Font.system(size: 40))
                        .offset(y: -38)
                )
        }
    }
}

private struct GradientCircle: View {
//    @State private var rotationAngle: Double = 0
    
    var body: some View {
        RadialGradient(
            colors: [.yellow, .white],
            center: .center,
            startRadius: 10,
            endRadius: 160
        )
        .ignoresSafeArea()
//        .overlay {
//            ZStack {
//                ForEach(0..<6, id: \.self) { index in
//                    RayView(index: index, totalRays: 12)
//                }
//            }
//            .rotationEffect(.degrees(rotationAngle))
//        }
//        .onAppear {
//            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
//                rotationAngle = 360
//            }
//        }
    }
}

//private struct RayView: View {
//    let index: Int
//    let totalRays: Int
//    
//    var body: some View {
//        if index % 2 == 0 {
//            LinearGradient(
//                colors: [
//                    .yellow,
//                    .clear
//                ],
//                startPoint: .bottom,
//                endPoint: .top
//            )
//                .frame(width: 80, height: 180)
//                .offset(y: -50)
//                .rotationEffect(.degrees(Double(index) * (360 / Double(totalRays / 6))))
//        } else {
//            EmptyView()
//        }
//    }
//}

struct TournamentDetailView: View {
    
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            Text(subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
        }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 16)
    }
}

struct TournamentHeaderView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(Color(.accent))
                }
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.accent))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
    }
}
