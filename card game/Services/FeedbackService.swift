//
//  FeedbackService.swift
//  card game
//
//  Created by Владислав Жуков on 01.05.2024.
//

import Foundation
#if os(iOS)
import UIKit
#endif


protocol IFeedbackService {
    func error()
    func success()
}

final class FeedbackService: IFeedbackService {
    #if os(iOS)
    let generator = UINotificationFeedbackGenerator()
    #endif
    
    let uiSettings: IGameUISettingsService
    
    init(uiSettings: IGameUISettingsService) {
        self.uiSettings = uiSettings
    }
    
    func error() {
        #if os(iOS)
        if uiSettings.isVibrationOn {
            generator.notificationOccurred(.error)
        }
        #endif
    }
    
    func success() {
        #if os(iOS)
        if uiSettings.isVibrationOn {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
        #endif
    }
}

