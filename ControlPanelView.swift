import SwiftUI

struct ControlPanelView: View {
    @EnvironmentObject var gameManager: TetrisGameManager
    @Environment(\.dismissWindow) var dismissWindow
    @State private var showingPauseMenu = false

    var body: some View {
        VStack(spacing: 25) {
            // Pause button at the top
            HStack {
                Spacer()
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
            .padding(.horizontal)

            // Score display
            HStack(spacing: 35) {
                VStack(spacing: 4) {
                    Text("\(gameManager.score)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("SCORE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.cyan)
                        .tracking(1)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 60)

                VStack(spacing: 4) {
                    Text("\(gameManager.level)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("LEVEL")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.purple)
                        .tracking(1)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 60)

                VStack(spacing: 4) {
                    Text("\(gameManager.linesCleared)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("LINES")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                        .tracking(1)
                }
            }
            .padding()

            // Control buttons
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

            // Game Over / Replay section
            if gameManager.isGameOver {
                VStack(spacing: 15) {
                    VStack(spacing: 8) {
                        Text("GAME OVER!")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.red)
                            .tracking(2)
                        Text("Final Score: \(gameManager.score)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 10)

                    // Replay button
                    Button(action: {
                        gameManager.startGame()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 24, weight: .bold))
                            Text("PLAY AGAIN")
                                .font(.system(size: 20, weight: .bold))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.green.opacity(0.5), radius: 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 2)
                        )
                )
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
        .alert("Game Paused", isPresented: $showingPauseMenu) {
            Button("Resume") {
                gameManager.pauseGame()
                showingPauseMenu = false
            }
            Button("End Game", role: .destructive) {
                dismissWindow(id: "GameBoardWindow")
                dismissWindow(id: "ControlPanelWindow")
                gameManager.resetGame()
                showingPauseMenu = false
            }
            Button("Cancel", role: .cancel) {
                showingPauseMenu = false
            }
        } message: {
            Text("What would you like to do?")
        }
    }
}
