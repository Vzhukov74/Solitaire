//
//  Network.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 20.04.2025.
//

import Foundation

struct Challenge {
    let id: UUID
    let value: String
    let year: Int
    let day: Int
    let deck: DeckShuffler
}

struct LeadersSheet: Codable {
    struct Leaders: Codable, Hashable {
        let id: String
        let name: String
        let points: Int
    }
    
    let leaders: [Leaders]
    let position: Int?
}

final class Network {
    
    struct ChallengeOfDay: Codable {
        let id: UUID
        let value: String
        let year: Int
        let day: Int
    }
    
    private struct ChallengeResult: Codable {
        let name: String
        let id: String
        let points: Int
    }
    
    private struct UploadChallengeRequest: Codable {
        let value: String
    }
    
    private let baseUrl: URL = URL(string: "https://mdlab.tech")! // http://127.0.0.1:8080
    
    func fetchChallengeOfDay() async throws -> Challenge {
        let path = "solitaire/challenge"
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "GET"
        
        let response = try await URLSession.shared.data(for: request)
        
        let challengeOfDay = try JSONDecoder().decode(ChallengeOfDay.self, from: response.0)
        let deck = try DeckShuffler(from: challengeOfDay.value)
        
        return Challenge(
            id: challengeOfDay.id,
            value: challengeOfDay.value,
            year: challengeOfDay.year,
            day: challengeOfDay.day,
            deck: deck
        )
    }
    
    func fetchLeadersSheet(id: String) async throws -> LeadersSheet {
        let path = "solitaire/player/rating?id=\(id)"
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "GET"
        
        let response = try await URLSession.shared.data(for: request)
        
        let leadersSheet = try JSONDecoder().decode(LeadersSheet.self, from: response.0)
        
        return leadersSheet
    }
    
    func sendResultOfChallenge(
        name: String,
        id: String,
        points: Int,
        challenge: Challenge
    ) async throws {
        let path = "solitaire/player/rating"
        
        let result = ChallengeResult(
            name: name,
            id: id,
            points: points
        )
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(result)
        
        _ = try await URLSession.shared.data(for: request)
    }
    
    func uploadGame(game: String) async throws {
        let path = "solitaire/challenge"
        
        let result = UploadChallengeRequest(value: game)
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(result)
        
        _ = try await URLSession.shared.data(for: request)
    }
}
