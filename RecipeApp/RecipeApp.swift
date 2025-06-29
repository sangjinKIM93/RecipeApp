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
struct RecipeApp: App {
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


// MARK: - 메인 컨텐츠 뷰
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var path = NavigationPath()
    @State private var showAddRecipe = false
    
    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                RecipeListView()
                    .navigationTitle("레시피")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showAddRecipe = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showAddRecipe) {
                        AddRecipeView()
                    }
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("My")
            }
            NavigationStack(path: $path) {
                SharedRecipeView()
                    .navigationTitle("공유")
                    .sheet(isPresented: $showAddRecipe) {
//                        AddRecipeView()
                    }
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Other")
            }
        }
    }
}
