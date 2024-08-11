//
//  FeedbackService.swift
//  card game
//
//  Created by Владислав Жуков on 01.05.2024.
//

import AVFoundation
import Foundation
#if os(iOS)
import UIKit
#endif


protocol IFeedbackService {
    func error()
    func success()

    func moveCard()
    func swapCard()
    func shuffleCardsStart()
    func shuffleCardsEnd()
    func won()
}

final class FeedbackService: IFeedbackService {
    #if os(iOS)
    let generator = UINotificationFeedbackGenerator()
    #endif
    
    private var player = AVAudioPlayer()
    
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
    
    func moveCard() {
        play(.cardMove)
        success()
    }
    
    func swapCard() {
        play(.cardSwap)
        success()
    }
    
    func shuffleCardsStart() {
        play(.cardsShuffleStart)
        success()
    }
    
    func shuffleCardsEnd() {
        play(.cardsShuffleEnd)
    }
    
    func won() {
        play(.won)
    }
    
    private func play(_ sound: Sound) {
        guard uiSettings.isSoundOn else { return }
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        } catch {
            print(error)
        }
    }
}

fileprivate enum Sound: String {
    case cardMove = "card move"
    case cardSwap = "card swap"
    case cardsShuffleEnd = "cards shuffle end"
    case cardsShuffleStart = "cards shuffle start"
    case won = "won"
}
