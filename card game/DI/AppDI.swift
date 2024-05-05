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
    
    private init() {}
    
    func service() -> IGameUISettingsService {
        GameUISettingsService()
    }
    
    func service() -> IFeedbackService {
        FeedbackService(uiSettings: service())
    }
    
    func service() -> IGamePersistentStore {
        gamePersistentStore
    }
}
