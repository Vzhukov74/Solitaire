//
//  AppDI.swift
//  card game
//
//  Created by Владислав Жуков on 30.04.2024.
//

import Foundation

final class AppDI {
    
    static let shared = AppDI()
    
    private init() {}
    
    func service() -> IGameUISettingsService {
        GameUISettingsService()
    }
    
}
