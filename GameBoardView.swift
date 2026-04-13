import RealityKit
import SwiftUI

struct GameBoardView: View {
    @EnvironmentObject var gameManager: TetrisGameManager
    @State private var rootEntity: Entity?

    var body: some View {
        ZStack {
            // Dark background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Top spacer
                Spacer()
                    .frame(height: 40)

                // Score display - ABOVE game board
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
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.5), radius: 15)
                )

                Spacer()
                    .frame(height: 25)

                // 3D Game Board - with its own background
                RealityView { content in
                    let root = Entity()
                    rootEntity = root

                    // Create game board
                    let board = createGameBoard()
                    board.position = SIMD3<Float>(0, 0, 0)
                    root.addChild(board)

                    // Add lighting
                    let light1 = PointLight()
                    light1.light.intensity = 10000
                    light1.position = [0, 0, 1]
                    root.addChild(light1)

                    let light2 = PointLight()
                    light2.light.intensity = 5000
                    light2.position = [0.5, 0, 0.5]
                    root.addChild(light2)

                    let light3 = PointLight()
                    light3.light.intensity = 5000
                    light3.position = [-0.5, 0, 0.5]
                    root.addChild(light3)

                    content.add(root)

                } update: { content in
                    if let root = rootEntity {
                        updateGameContent(root: root)
                    }
                }
                .frame(width: 420, height: 750)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.cyan.opacity(0.5), Color.purple.opacity(0.5),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 30)
                )

                Spacer()
                    .frame(height: 25)

                // Control buttons - BELOW game board
                HStack(spacing: 22) {
                    Button(action: { gameManager.moveLeft() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 42))
                            Text("LEFT")
                                .font(.system(size: 10, weight: .black))
                                .tracking(0.5)
                        }
                        .frame(width: 95, height: 95)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.blue)
                                .shadow(color: Color.blue.opacity(0.6), radius: 12)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { gameManager.rotate() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 42))
                            Text("ROTATE")
                                .font(.system(size: 10, weight: .black))
                                .tracking(0.5)
                        }
                        .frame(width: 95, height: 95)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.purple)
                                .shadow(color: Color.purple.opacity(0.6), radius: 12)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { gameManager.moveRight() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 42))
                            Text("RIGHT")
                                .font(.system(size: 10, weight: .black))
                                .tracking(0.5)
                        }
                        .frame(width: 95, height: 95)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.blue)
                                .shadow(color: Color.blue.opacity(0.6), radius: 12)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { gameManager.drop() }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 42))
                            Text("DROP")
                                .font(.system(size: 10, weight: .black))
                                .tracking(0.5)
                        }
                        .frame(width: 95, height: 95)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.cyan)
                                .shadow(color: Color.cyan.opacity(0.6), radius: 12)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                    .frame(height: 40)
            }

            // Game Over overlay
            if gameManager.isGameOver {
                VStack(spacing: 12) {
                    Text("GAME OVER!")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.red)
                        .tracking(2)
                    Text("Final Score: \(gameManager.score)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.red, lineWidth: 4)
                        )
                        .shadow(color: Color.red.opacity(0.5), radius: 30)
                )
            }
        }
    }

    func createGameBoard() -> Entity {
        let boardEntity = Entity()

        let gridWidth: Float = 0.35
        let gridHeight: Float = 0.7
        let blockSize: Float = gridWidth / 10

        // Back panel
        var backMaterial = SimpleMaterial()
        backMaterial.color = .init(tint: UIColor(red: 0.08, green: 0.08, blue: 0.25, alpha: 1.0))

        let backPanel = ModelEntity(
            mesh: .generateBox(width: gridWidth + 0.02, height: gridHeight + 0.02, depth: 0.005),
            materials: [backMaterial]
        )
        backPanel.position = SIMD3<Float>(0, 0, -0.01)
        backPanel.name = "backpanel"
        boardEntity.addChild(backPanel)

        // Vertical grid lines
        for i in 0...10 {
            let x = Float(i) * blockSize - gridWidth / 2
            var lineMaterial = SimpleMaterial()
            lineMaterial.color = .init(tint: UIColor.white.withAlphaComponent(0.5))

            let line = ModelEntity(
                mesh: .generateBox(width: 0.002, height: gridHeight, depth: 0.002),
                materials: [lineMaterial]
            )
            line.position = SIMD3<Float>(x, 0, 0)
            line.name = "gridline"
            boardEntity.addChild(line)
        }

        // Horizontal grid lines
        for i in 0...20 {
            let y = Float(i) * (gridHeight / 20) - gridHeight / 2
            var lineMaterial = SimpleMaterial()
            lineMaterial.color = .init(tint: UIColor.white.withAlphaComponent(0.5))

            let line = ModelEntity(
                mesh: .generateBox(width: gridWidth, height: 0.002, depth: 0.002),
                materials: [lineMaterial]
            )
            line.position = SIMD3<Float>(0, y, 0)
            line.name = "gridline"
            boardEntity.addChild(line)
        }

        boardEntity.name = "gameboard"
        return boardEntity
    }

    func updateGameContent(root: Entity) {
        guard let board = root.findEntity(named: "gameboard") else { return }

        // Remove old blocks
        for child in board.children {
            if child.name.starts(with: "block_") {
                child.removeFromParent()
            }
        }

        let gridWidth: Float = 0.35
        let gridHeight: Float = 0.7
        let blockSize: Float = gridWidth / 10

        // Render locked blocks
        for (rowIndex, row) in gameManager.grid.enumerated() {
            for (colIndex, cell) in row.enumerated() {
                if let shape = cell {
                    let block = createBlock(shape: shape, size: blockSize)
                    let x = Float(colIndex) * blockSize - gridWidth / 2 + blockSize / 2
                    let y = gridHeight / 2 - Float(rowIndex) * (gridHeight / 20) - (gridHeight / 40)
                    block.position = SIMD3<Float>(x, y, 0.01)
                    block.name = "block_\(rowIndex)_\(colIndex)"
                    board.addChild(block)
                }
            }
        }

        // Render current piece
        if let piece = gameManager.currentPiece {
            for (i, row) in piece.blocks.enumerated() {
                for (j, cell) in row.enumerated() where cell == 1 {
                    let block = createBlock(shape: piece.shape, size: blockSize)
                    let gridX = piece.x + j
                    let gridY = piece.y + i
                    let x = Float(gridX) * blockSize - gridWidth / 2 + blockSize / 2
                    let y = gridHeight / 2 - Float(gridY) * (gridHeight / 20) - (gridHeight / 40)
                    block.position = SIMD3<Float>(x, y, 0.015)
                    block.name = "block_current_\(i)_\(j)"
                    board.addChild(block)
                }
            }
        }
    }

    func createBlock(shape: TetrisShape, size: Float) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: size * 0.88, cornerRadius: size * 0.12)

        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(shape.color))
        material.metallic = .init(floatLiteral: 0.85)
        material.roughness = .init(floatLiteral: 0.15)

        return ModelEntity(mesh: mesh, materials: [material])
    }
}
