//
//  RecipeAppApp.swift
//  RecipeApp
//
//  Created by 김상진 on 5/17/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct RecipeAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Recipe.self)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
