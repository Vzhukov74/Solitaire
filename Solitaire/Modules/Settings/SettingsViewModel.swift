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
    @Published var selectedBackId: String
    @Published var selectedFrontId: String
    @Published var selectedTableColorsId: String
    
    private(set) var backs: [(String, Image)] = []
    private(set) var fronts: [(String, [Image])] = []
    private(set) var tableColors: [String] = []
    
    private let uiSettings: IGameUISettingsService
    private let feedbackService: IFeedbackService
    private let cardUIServices: ICardUIServices
    
    init(
        uiSettings: IGameUISettingsService,
        feedbackService: IFeedbackService,
        cardUIServices: ICardUIServices
    ) {
        self.uiSettings = uiSettings
        self.feedbackService = feedbackService
        self.cardUIServices = cardUIServices
        
        self.isSoundOn = uiSettings.isSoundOn
        self.isVibrationOn = uiSettings.isVibrationOn
        self.selectedBackId = cardUIServices.selectedBackId
        self.backs = cardUIServices.allBacks
        self.selectedFrontId = cardUIServices.selectedFrontId
        self.fronts = cardUIServices.allFronts
        self.selectedTableColorsId = cardUIServices.selectedTableId
        self.tableColors = cardUIServices.allTableBackgrounds
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

    func select(cardBackId: String) {
        cardUIServices.select(back: cardBackId)
        selectedBackId = cardBackId
    }
    
    func select(cardFrontId: String) {
        cardUIServices.select(front: cardFrontId)
        selectedFrontId = cardFrontId
    }
    
    func select(tableColorsId: String) {
        cardUIServices.select(table: tableColorsId)
        selectedTableColorsId = tableColorsId
    }
}
