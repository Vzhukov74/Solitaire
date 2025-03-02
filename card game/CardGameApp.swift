//
//  card_gameApp.swift
//  card game
//
//  Created by Владислав Жуков on 30.03.2024.
//

import SwiftUI
//import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
      //FirebaseApp.configure()
      return true
  }
}

@main
struct card_gameApp: App {
    @Environment(\.scenePhase) var scenePhase
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
    private let scoreStore = ScoreStore()
    
    var body: some Scene {
        WindowGroup {
            MainView(
                vm: MainViewModel(
                    gameStore: AppDI.shared.service(),
                    scoreStore: scoreStore
                )
            )
            .onAppear {
                let feedbackService: IFeedbackService = AppDI.shared.service()
                feedbackService.prepare()
            }
        }
            .defaultSize(width: 500.0, height: 800.0)
    }
}
