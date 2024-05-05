//
//  SettingsViewModel.swift
//  card game
//
//  Created by Владислав Жуков on 30.04.2024.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var isSoundOn: Bool
    @Published var isVibrationOn: Bool
    
    private let uiSettings: IGameUISettingsService
    private let feedbackService: IFeedbackService
    
    init(uiSettings: IGameUISettingsService, feedbackService: IFeedbackService) {
        self.uiSettings = uiSettings
        self.feedbackService = feedbackService
        
        self.isSoundOn = uiSettings.isSoundOn
        self.isVibrationOn = uiSettings.isVibrationOn
    }
    
    func toggleSound() {
        uiSettings.toggleSound()
        isSoundOn = uiSettings.isSoundOn
        feedbackService.success()
    }
    
    func toggleVibration() {
        uiSettings.toggleVibration()
        isVibrationOn = uiSettings.isVibrationOn
        feedbackService.success()
    }

    // фон стола
    // ui карт ??
}
