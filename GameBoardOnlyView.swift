import RealityKit
import SwiftUI

struct GameBoardOnlyView: View {
    @EnvironmentObject var gameManager: TetrisGameManager
    @State private var rootEntity: Entity?
    @State private var isDragging = false
    @State private var dragStartX: Float = 0
    @State private var lastMoveTime = Date()
    @State private var lastTapTime = Date()
    @State private var tapCount = 0

    var body: some View {
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
        .contentShape(Rectangle())
        .gesture(
            SpatialTapGesture()
                .onEnded { _ in
                    if gameManager.currentPiece != nil && !gameManager.isPaused
                        && !gameManager.isGameOver
                    {
                        let now = Date()
                        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)

                        // If tapped within 0.2 seconds, it's a double tap
                        if timeSinceLastTap < 0.2 && tapCount == 1 {
                            // Double tap = DROP (immediate)
                            gameManager.drop()
                            tapCount = 0
                            lastTapTime = Date.distantPast
                        } else {
                            // First tap - wait to see if it's a double tap
                            tapCount = 1
                            lastTapTime = now

                            // Delay the rotation by 0.2 seconds to detect double tap
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [now] in
                                if self.tapCount == 1 && self.lastTapTime == now {
                                    gameManager.rotate()
                                    self.tapCount = 0
                                }
                            }
                        }
                    }
                }
        )
        .gesture(
            DragGesture(minimumDistance: 35)
                .onChanged { value in
                    // Drag anywhere on game board to move current piece
                    if gameManager.currentPiece != nil && !gameManager.isPaused
                        && !gameManager.isGameOver
                    {
                        if !isDragging {
                            isDragging = true
                            dragStartX = Float(value.startLocation.x)
                        }

                        let now = Date()
                        let timeSinceLastMove = now.timeIntervalSince(lastMoveTime)

                        // Require 0.2 seconds between moves
                        guard timeSinceLastMove > 0.2 else { return }

                        let currentX = Float(value.location.x)
                        let deltaX = currentX - dragStartX

                        // Move piece left/right - 100 pixel threshold
                        if deltaX > 100 {  // Moved right (in screen pixels)
                            gameManager.moveRight()
                            dragStartX = currentX
                            lastMoveTime = now
                        } else if deltaX < -100 {  // Moved left (in screen pixels)
                            gameManager.moveLeft()
                            dragStartX = currentX
                            lastMoveTime = now
                        }
                    }
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }

    func createGameBoard() -> Entity {
        let boardEntity = Entity()

        let gridWidth: Float = 0.4
        let gridHeight: Float = 0.8
        let blockSize: Float = gridWidth / 10

        // Back panel
        var backMaterial = SimpleMaterial()
        backMaterial.color = .init(tint: UIColor(red: 0.08, green: 0.08, blue: 0.25, alpha: 1.0))

        let backPanel = ModelEntity(
            mesh: .generateBox(width: gridWidth + 0.02, height: gridHeight + 0.02, depth: 0.01),
            materials: [backMaterial]
        )
        backPanel.position = SIMD3<Float>(0, 0, -0.02)
        backPanel.name = "backpanel"
        boardEntity.addChild(backPanel)

        // Vertical grid lines
        for i in 0...10 {
            let x = Float(i) * blockSize - gridWidth / 2
            var lineMaterial = SimpleMaterial()
            lineMaterial.color = .init(tint: UIColor.white.withAlphaComponent(0.5))

            let line = ModelEntity(
                mesh: .generateBox(width: 0.003, height: gridHeight, depth: 0.003),
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
                mesh: .generateBox(width: gridWidth, height: 0.003, depth: 0.003),
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

        // Remove ALL old blocks (both locked and current pieces)
        let childrenToRemove = board.children.filter { child in
            child.name.starts(with: "block_")
        }
        for child in childrenToRemove {
            child.removeFromParent()
        }

        let gridWidth: Float = 0.4
        let gridHeight: Float = 0.8
        let blockSize: Float = gridWidth / 10

        // Render locked blocks first
        for (rowIndex, row) in gameManager.grid.enumerated() {
            for (colIndex, cell) in row.enumerated() {
                if let shape = cell {
                    let block = createBlock(shape: shape, size: blockSize, isInteractive: false)
                    let x = Float(colIndex) * blockSize - gridWidth / 2 + blockSize / 2
                    let y = gridHeight / 2 - Float(rowIndex) * (gridHeight / 20) - (gridHeight / 40)
                    block.position = SIMD3<Float>(x, y, 0.01)
                    block.name = "block_locked_\(rowIndex)_\(colIndex)"
                    board.addChild(block)
                }
            }
        }

        // Render current piece on top (interactive!)
        if let piece = gameManager.currentPiece {
            for (i, row) in piece.blocks.enumerated() {
                for (j, cell) in row.enumerated() where cell == 1 {
                    let block = createBlock(
                        shape: piece.shape,
                        size: blockSize,
                        isInteractive: true
                    )
                    let gridX = piece.x + j
                    let gridY = piece.y + i

                    // Only render if within bounds
                    if gridX >= 0 && gridX < 10 && gridY >= 0 && gridY < 20 {
                        let x = Float(gridX) * blockSize - gridWidth / 2 + blockSize / 2
                        let y =
                            gridHeight / 2 - Float(gridY) * (gridHeight / 20) - (gridHeight / 40)
                        block.position = SIMD3<Float>(x, y, 0.015)
                        block.name = "block_current_\(i)_\(j)_\(gridX)_\(gridY)"
                        board.addChild(block)
                    }
                }
            }
        }
    }

    func createBlock(shape: TetrisShape, size: Float, isInteractive: Bool) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: size * 0.88, cornerRadius: size * 0.12)

        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(shape.color))
        material.metallic = .init(floatLiteral: 0.85)
        material.roughness = .init(floatLiteral: 0.15)

        let block = ModelEntity(mesh: mesh, materials: [material])

        // Make current piece blocks interactive with collision
        if isInteractive {
            block.components.set(InputTargetComponent())
            block.components.set(
                CollisionComponent(shapes: [
                    .generateBox(size: [size * 0.88, size * 0.88, size * 0.88])
                ])
            )

            // Add a subtle glow to show it's interactive
            var glowMaterial = SimpleMaterial()
            glowMaterial.color = .init(tint: UIColor(shape.color).withAlphaComponent(0.3))
            glowMaterial.metallic = .init(floatLiteral: 1.0)
        }

        return block
    }
}
