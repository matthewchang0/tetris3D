import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: TetrisGameManager
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "cube.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0, green: 1, blue: 1), .blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("TETRIS50")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0, green: 1, blue: 1), .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    
                    Text("A visionOS edition of the iconic Tetris")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                if !gameManager.isPlaying {
                    Button {
                        openWindow(id: "GameWindow")
                        gameManager.startGame()
                        // Close the menu window after starting game
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismissWindow(id: "MenuWindow")
                        }
                    } label: {
                        Label("Start Game", systemImage: "play.fill")
                            .font(.title2)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Controls:")
                            .font(.headline)
                        Text("• Single tap → Rotate")
                        Text("• Double tap → Drop")
                        Text("• Drag left/right → Move")
                        Text("• Look at the block you want to move!")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                } else {
                    VStack(spacing: 15) {
                        Text("Game in Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(gameManager.score)")
                                    .font(.system(size: 36, weight: .bold))
                                Text("Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(gameManager.level)")
                                    .font(.system(size: 36, weight: .bold))
                                Text("Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(gameManager.linesCleared)")
                                    .font(.system(size: 36, weight: .bold))
                                Text("Lines")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
    }
}

struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}
