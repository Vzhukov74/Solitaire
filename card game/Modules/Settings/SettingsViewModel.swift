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
    
    init(uiSettings: IGameUISettingsService) {
        self.uiSettings = uiSettings
        
        self.isSoundOn = uiSettings.isSoundOn
        self.isVibrationOn = uiSettings.isVibrationOn
    }
    
    // звук
    // вибрации
    // фон стола
    // ui карт ??
}
