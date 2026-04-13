import SwiftUI

struct CombinedGameView: View {
    @EnvironmentObject var gameManager: TetrisGameManager
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openWindow) var openWindow
    @State private var showingPauseMenu = false

    var body: some View {
        VStack(spacing: 20) {
            // Score display at top
            HStack(spacing: 35) {
                VStack(spacing: 4) {
                    Text("\(gameManager.score)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("SCORE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.cyan)
                        .tracking(1)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 55)

                VStack(spacing: 4) {
                    Text("\(gameManager.level)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("LEVEL")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.purple)
                        .tracking(1)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 55)

                VStack(spacing: 4) {
                    Text("\(gameManager.linesCleared)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("LINES")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                        .tracking(1)
                }

                // Pause button
                Button(action: {
                    if !gameManager.isGameOver {
                        gameManager.pauseGame()
                        if gameManager.isPaused {
                            showingPauseMenu = true
                        }
                    }
                }) {
                    Image(systemName: gameManager.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
                .disabled(gameManager.isGameOver)
                .opacity(gameManager.isGameOver ? 0.3 : 1.0)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )

            // 3D Game Board
            GameBoardOnlyView()

            // Control buttons at bottom
            VStack(spacing: 15) {
                HStack(spacing: 18) {
                    Button(action: { gameManager.moveLeft() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 40))
                            Text("LEFT")
                                .font(.system(size: 9, weight: .black))
                        }
                        .frame(width: 85, height: 85)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                    .disabled(gameManager.isGameOver)
                    .opacity(gameManager.isGameOver ? 0.5 : 1.0)

                    // SWAPPED: Right button now in middle
                    Button(action: { gameManager.moveRight() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 40))
                            Text("RIGHT")
                                .font(.system(size: 9, weight: .black))
                        }
                        .frame(width: 85, height: 85)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                    .disabled(gameManager.isGameOver)
                    .opacity(gameManager.isGameOver ? 0.5 : 1.0)

                    // SWAPPED: Rotate button now third
                    Button(action: { gameManager.rotate() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 40))
                            Text("ROTATE")
                                .font(.system(size: 9, weight: .black))
                        }
                        .frame(width: 85, height: 85)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(15)
                    }
                    .disabled(gameManager.isGameOver)
                    .opacity(gameManager.isGameOver ? 0.5 : 1.0)

                    Button(action: { gameManager.drop() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 40))
                            Text("DROP")
                                .font(.system(size: 9, weight: .black))
                        }
                        .frame(width: 85, height: 85)
                        .foregroundColor(.white)
                        .background(Color.cyan)
                        .cornerRadius(15)
                    }
                    .disabled(gameManager.isGameOver)
                    .opacity(gameManager.isGameOver ? 0.5 : 1.0)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.05, blue: 0.15),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                // Completely redesigned Game Over screen
                if gameManager.isGameOver {
                    ZStack {
                        // Semi-transparent backdrop
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()

                        // Game Over Card - Compact version
                        VStack(spacing: 12) {
                            // Title
                            Text("GAME OVER")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .red, radius: 8)

                            // Play Again Button
                            Button(action: {
                                withAnimation {
                                    gameManager.startGame()
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 22))
                                    Text("PLAY AGAIN")
                                        .font(.system(size: 18, weight: .bold))
                                        .tracking(1)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .green.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                                .shadow(color: .green.opacity(0.6), radius: 12, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.red, .orange, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2.5
                                        )
                                )
                                .shadow(color: .red.opacity(0.5), radius: 30)
                        )
                        .frame(maxWidth: 320)
                    }
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .alert("Game Paused", isPresented: $showingPauseMenu) {
                Button("Resume") {
                    gameManager.pauseGame()
                    showingPauseMenu = false
                }
                Button("End Game", role: .destructive) {
                    // Reset game first
                    gameManager.resetGame()
                    showingPauseMenu = false

                    // Close game window and open menu
                    Task { @MainActor in
                        dismissWindow(id: "GameWindow")
                        try? await Task.sleep(for: .milliseconds(300))
                        openWindow(id: "MenuWindow")
                    }
                }
                Button("Cancel", role: .cancel) {
                    showingPauseMenu = false
                }
            } message: {
                Text("What would you like to do?")
            }
        }
    }
}
