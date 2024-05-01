//
//  FeedbackService.swift
//  card game
//
//  Created by Владислав Жуков on 01.05.2024.
//

import Foundation

protocol IFeedbackService {
    func error()
    func success()
}

final class FeedbackService: IFeedbackService {
    #if iOS
    let generator = UINotificationFeedbackGenerator()
    #endif
    
    let uiSettings: IGameUISettingsService
    
    init(uiSettings: IGameUISettingsService) {
        self.uiSettings = uiSettings
    }
    
    func error() {
        #if iOS
        if uiSettings.isVibrationOn {
            generator.notificationOccurred(.error)
        }
        #endif
    }
    
    func success() {
        #if iOS
        if uiSettings.isVibrationOn {
            generator.notificationOccurred(.success)
        }
        #endif
    }
}

