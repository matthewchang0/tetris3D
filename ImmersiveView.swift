import RealityKit
import SwiftUI

struct ImmersiveTetrisView: View {
    @EnvironmentObject var gameManager: TetrisGameManager
    @State private var boardEntity: Entity?

    var body: some View {
        ZStack {
            RealityView { content in
                let board = createGameBoard()
                boardEntity = board
                content.add(board)

                let light = PointLight()
                light.light.intensity = 1000
                light.position = [0, 1, 0.5]
                content.add(light)

            } update: { content in
                if let board = boardEntity {
                    updateGameBoard(board: board)
                }
            }
            .gesture(
                TapGesture()
                    .targetedToAnyEntity()
                    .onEnded { _ in
                        gameManager.rotate()
                    }
            )

            // Control Panel - Bottom Center
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    // Game Controls
                    HStack(spacing: 30) {
                        // Left
                        Button {
                            gameManager.moveLeft()
                        } label: {
                            Image(systemName: "arrowtriangle.left.fill")
                                .font(.system(size: 30))
                                .frame(width: 80, height: 80)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        // Rotate
                        Button {
                            gameManager.rotate()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 30))
                                .frame(width: 80, height: 80)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)

                        // Right
                        Button {
                            gameManager.moveRight()
                        } label: {
                            Image(systemName: "arrowtriangle.right.fill")
                                .font(.system(size: 30))
                                .frame(width: 80, height: 80)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        // Drop
                        Button {
                            gameManager.drop()
                        } label: {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 30))
                                .frame(width: 80, height: 80)
                        }
                        .buttonStyle(.bordered)
                        .tint(.cyan)
                    }

                    // Instructions
                    Text("Tap buttons to control • Tap board to rotate")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(40)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.bottom, 60)
            }
        }
    }

    func createGameBoard() -> Entity {
        let boardEntity = Entity()
        boardEntity.position = [0, 1.5, -1.0]

        let gridWidth: Float = 0.4
        let gridHeight: Float = 0.8
        let blockSize: Float = gridWidth / 10

        var backMaterial = SimpleMaterial()
        backMaterial.color = .init(tint: .black.withAlphaComponent(0.3))

        let backPanel = ModelEntity(
            mesh: .generateBox(width: gridWidth + 0.02, height: gridHeight + 0.02, depth: 0.01),
            materials: [backMaterial]
        )
        backPanel.position.z = -blockSize / 2
        boardEntity.addChild(backPanel)

        for i in 0...10 {
            let x = Float(i) * blockSize - gridWidth / 2
            var lineMaterial = SimpleMaterial()
            lineMaterial.color = .init(tint: .white.withAlphaComponent(0.2))

            let line = ModelEntity(
                mesh: .generateBox(width: 0.001, height: gridHeight, depth: 0.001),
                materials: [lineMaterial]
            )
            line.position = [x, 0, 0]
            boardEntity.addChild(line)
        }

        for i in 0...20 {
            let y = Float(i) * (gridHeight / 20) - gridHeight / 2
            var lineMaterial = SimpleMaterial()
            lineMaterial.color = .init(tint: .white.withAlphaComponent(0.2))

            let line = ModelEntity(
                mesh: .generateBox(width: gridWidth, height: 0.001, depth: 0.001),
                materials: [lineMaterial]
            )
            line.position = [0, y, 0]
            boardEntity.addChild(line)
        }

        return boardEntity
    }

    func updateGameBoard(board: Entity) {
        for child in board.children {
            if child.name.starts(with: "block_") {
                child.removeFromParent()
            }
        }

        let gridWidth: Float = 0.4
        let gridHeight: Float = 0.8
        let blockSize: Float = gridWidth / 10

        for (rowIndex, row) in gameManager.grid.enumerated() {
            for (colIndex, cell) in row.enumerated() {
                if let shape = cell {
                    let block = createBlock(shape: shape, size: blockSize)
                    let x = Float(colIndex) * blockSize - gridWidth / 2 + blockSize / 2
                    let y = gridHeight / 2 - Float(rowIndex) * (gridHeight / 20) - (gridHeight / 40)
                    block.position = [x, y, 0]
                    block.name = "block_\(rowIndex)_\(colIndex)"
                    board.addChild(block)
                }
            }
        }

        if let piece = gameManager.currentPiece {
            for (i, row) in piece.blocks.enumerated() {
                for (j, cell) in row.enumerated() where cell == 1 {
                    let block = createBlock(shape: piece.shape, size: blockSize)
                    let gridX = piece.x + j
                    let gridY = piece.y + i
                    let x = Float(gridX) * blockSize - gridWidth / 2 + blockSize / 2
                    let y = gridHeight / 2 - Float(gridY) * (gridHeight / 20) - (gridHeight / 40)
                    block.position = [x, y, 0.01]
                    block.name = "block_current_\(i)_\(j)"
                    board.addChild(block)
                }
            }
        }
    }

    func createBlock(shape: TetrisShape, size: Float) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: size * 0.95)

        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(shape.color))
        material.metallic = .init(floatLiteral: 0.3)
        material.roughness = .init(floatLiteral: 0.4)

        return ModelEntity(mesh: mesh, materials: [material])
    }
}
