//
//  AppDI.swift
//  card game
//
//  Created by Владислав Жуков on 30.04.2024.
//

import Foundation

final class AppDI {
    
    static let shared = AppDI()
    
    private lazy var gamePersistentStore = GamePersistentStore()
    private lazy var gameUISettingsService = GameUISettingsService()
    private lazy var cardUIServices = CardUIServices()
    private lazy var feedbackService = FeedbackService(uiSettings: service())
    
    private init() {}
    
    func service() -> IGameUISettingsService {
        gameUISettingsService
    }
    
    func service() -> IFeedbackService {
        feedbackService
    }
    
    func service() -> IGamePersistentStore {
        gamePersistentStore
    }
    
    func service() -> ICardUIServices {
        cardUIServices
    }
    
    func service() -> UserInfo {
        UserInfo()
    }
}
