import SwiftUI

@main
struct tetrisApp: App {
    @StateObject private var gameManager = TetrisGameManager()
    
    var body: some Scene {
        // Main Menu Window
        WindowGroup(id: "MenuWindow") {
            ContentView()
                .environmentObject(gameManager)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        
        // Combined Game Window - Board + Controls together!
        WindowGroup(id: "GameWindow") {
            CombinedGameView()
                .environmentObject(gameManager)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 1.3, depth: 0.4, in: .meters)
    }
}
