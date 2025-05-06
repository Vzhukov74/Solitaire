//
//  Network.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 20.04.2025.
//

import Foundation

struct LeadersSheet: Codable {
    struct Leaders: Codable, Hashable {
        let id: String
        let name: String
        let points: Int
        let place: Int
    }
    
    let leaders: [Leaders]
}

final class Network {
    private struct ChallengeOfWeek: Codable {
        let id: String
        let week: Int
        let year: Int
        let challenge: String
    }
    
    private struct ChallengeResult: Codable {
        let name: String
        let id: String
        let points: Int
    }
    
    private struct GameRequest: Codable {
        let game: String
    }
    
    private let baseUrl: URL = URL(string: "https://mdlab.tech")! // http://127.0.0.1:8080
    
    func fetchChallengeOfWeek() async throws -> DeckShuffler {
        let path = "solitaire/challenge"
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "GET"
        
        let response = try await URLSession.shared.data(for: request)
        
        let challengeOfWeek = try JSONDecoder().decode(Network.ChallengeOfWeek.self, from: response.0)
        
        return try DeckShuffler(from: challengeOfWeek.challenge)
    }
    
    func fetchLeadersSheet() async throws -> LeadersSheet {
        let path = "solitaire/leaders"
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "GET"
        
        let response = try await URLSession.shared.data(for: request)
        
        let leadersSheet = try JSONDecoder().decode(LeadersSheet.self, from: response.0)
        
        return leadersSheet
    }
    
    func sendResultOfChallenge(name: String, id: String, points: Int) async throws -> LeadersSheet {
        let path = "solitaire/result"
        
        let result = ChallengeResult(
            name: name,
            id: id,
            points: points
        )
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(result)
        
        let response = try await URLSession.shared.data(for: request)
        
        let leadersSheet = try JSONDecoder().decode(LeadersSheet.self, from: response.0)
        
        return leadersSheet
    }
    
    func uploadGame(game: String) async throws {
        let path = "solitaire/game"
        
        let result = GameRequest(game: game)
        
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(result)
        
        _ = try await URLSession.shared.data(for: request)
    }
}
