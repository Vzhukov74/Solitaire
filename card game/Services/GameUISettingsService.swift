//
//  GameUISettingsService.swift
//  card game
//
//  Created by Владислав Жуков on 30.04.2024.
//

import SwiftUI

protocol IGameUISettingsService {
    var cardBack: Image { get }
    var tableBg: Image { get }
    var isSoundOn: Bool { get }
    var isVibrationOn: Bool { get }
    
    func cardImage(for card: Card) -> Image
    
    func toggleSound()
    func toggleVibration()
}

final class GameUISettingsService: IGameUISettingsService {
    
    var cardBack: Image {
        Image("card_back")
    }
    var tableBg: Image { 
        Image("card_back")
    }
    
    @UserDefault(wrappedValue: true, "com.solitaire.game.sound.key")
    private(set) var isSoundOn: Bool
    @UserDefault(wrappedValue: true, "com.solitaire.game.vibration.key")
    private(set) var isVibrationOn: Bool
    
    init() {
        
    }
    
    func cardImage(for card: Card) -> Image {
        Image("card_back")
    }
    
    func toggleSound() {
        isSoundOn.toggle()
    }
    
    func toggleVibration() {
        isVibrationOn.toggle()
    }
}
