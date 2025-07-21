//
//  UserInfo.swift
//  Solitaire
//
//  Created by Vladislav Zhukov on 22.04.2025.
//

import Foundation

final class UserInfo {
    private enum Const {
        static let userIdKey: String = "com.solitaire.game.user.id.v2.key"
        static let userNameKey: String = "com.solitaire.game.user.name.v2.key"
        static let userAskForReviewKey: String = "com.solitaire.game.user.ask.for.review.v1.key"
    }
    
    private let userDefaults: UserDefaults
    
    var userId: String {
        var userIdValue = userDefaults.string(forKey: Const.userIdKey)
        if userIdValue == nil {
            userIdValue = UUID().uuidString.lowercased()
            userDefaults.set(userIdValue, forKey: Const.userIdKey)
            
            return userIdValue!
        } else {
            return userIdValue!
        }
    }
    
    var userAskForReview: Bool {
        userDefaults.bool(forKey: Const.userAskForReviewKey)
    }
    
    var userName: String {
        userDefaults.string(forKey: Const.userNameKey) ?? ""
    }
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func set(name: String) {
        userDefaults.set(name, forKey: Const.userNameKey)
    }
    
    func setUserAskForReview() {
        userDefaults.set(true, forKey: Const.userAskForReviewKey)
    }
}
