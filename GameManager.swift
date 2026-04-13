import Combine
import SwiftUI

// MARK: - Game State Models
enum TetrisShape: CaseIterable {
    case i, o, t, s, z, j, l

    var blocks: [[Int]] {
        switch self {
        case .i: return [[1, 1, 1, 1]]
        case .o: return [[1, 1], [1, 1]]
        case .t: return [[0, 1, 0], [1, 1, 1]]
        case .s: return [[0, 1, 1], [1, 1, 0]]
        case .z: return [[1, 1, 0], [0, 1, 1]]
        case .j: return [[1, 0, 0], [1, 1, 1]]
        case .l: return [[0, 0, 1], [1, 1, 1]]
        }
    }

    var color: Color {
        switch self {
        case .i: return Color(red: 0, green: 1, blue: 1)
        case .o: return .yellow
        case .t: return .purple
        case .s: return .green
        case .z: return .red
        case .j: return .blue
        case .l: return Color(red: 1, green: 0.5, blue: 0)
        }
    }
}

struct TetrisPiece {
    var shape: TetrisShape
    var blocks: [[Int]]
    var x: Int
    var y: Int

    init(shape: TetrisShape) {
        self.shape = shape
        self.blocks = shape.blocks
        self.x = 3
        self.y = 0
    }

    mutating func rotate() {
        let rows = blocks.count
        let cols = blocks[0].count
        var rotated = Array(repeating: Array(repeating: 0, count: rows), count: cols)

        for i in 0..<rows {
            for j in 0..<cols {
                rotated[j][rows - 1 - i] = blocks[i][j]
            }
        }
        blocks = rotated
    }
}

// MARK: - Game Manager
@MainActor
class TetrisGameManager: ObservableObject {
    @Published var grid: [[TetrisShape?]] = Array(
        repeating: Array(repeating: nil, count: 10),
        count: 20
    )
    @Published var currentPiece: TetrisPiece?
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var linesCleared: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var isPlaying: Bool = false

    private var timer: Timer?
    private let rows = 20
    private let cols = 10

    func startGame() {
        grid = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        score = 0
        level = 1
        linesCleared = 0
        isGameOver = false
        isPaused = false
        isPlaying = true
        spawnNewPiece()
        startTimer()
    }

    func pauseGame() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            startTimer()
        }
    }

    func resetGame() {
        timer?.invalidate()
        isPlaying = false
        isGameOver = false
        currentPiece = nil
    }

    private func startTimer() {
        timer?.invalidate()
        let interval = max(0.1, 1.0 - Double(level - 1) * 0.1)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.moveDown()
            }
        }
    }

    func spawnNewPiece() {
        let shape = TetrisShape.allCases.randomElement()!
        currentPiece = TetrisPiece(shape: shape)

        if !isValidPosition() {
            isGameOver = true
            isPlaying = false
            currentPiece = nil  // Clear the piece immediately
            timer?.invalidate()
        }
    }

    func moveLeft() {
        guard !isPaused, !isGameOver, var piece = currentPiece else { return }
        piece.x -= 1
        if isValidPosition(piece: piece) {
            currentPiece = piece
        }
    }

    func moveRight() {
        guard !isPaused, !isGameOver, var piece = currentPiece else { return }
        piece.x += 1
        if isValidPosition(piece: piece) {
            currentPiece = piece
        }
    }

    func moveDown() {
        guard !isPaused, !isGameOver, var piece = currentPiece else { return }
        piece.y += 1

        if isValidPosition(piece: piece) {
            currentPiece = piece
        } else {
            lockPiece()
            clearLines()

            // Don't spawn new piece if game is about to end
            if !isGameOver {
                spawnNewPiece()
            }
        }
    }

    func rotate() {
        guard !isPaused, !isGameOver, var piece = currentPiece else { return }
        piece.rotate()
        if isValidPosition(piece: piece) {
            currentPiece = piece
        }
    }

    func drop() {
        guard !isPaused, !isGameOver, var piece = currentPiece else { return }
        while isValidPosition(piece: piece) {
            piece.y += 1
        }
        piece.y -= 1
        currentPiece = piece
        moveDown()
    }

    private func isValidPosition(piece: TetrisPiece? = nil) -> Bool {
        let testPiece = piece ?? currentPiece
        guard let testPiece = testPiece else { return false }

        for (i, row) in testPiece.blocks.enumerated() {
            for (j, cell) in row.enumerated() where cell == 1 {
                let gridX = testPiece.x + j
                let gridY = testPiece.y + i

                if gridX < 0 || gridX >= cols || gridY >= rows {
                    return false
                }

                if gridY >= 0 && grid[gridY][gridX] != nil {
                    return false
                }
            }
        }
        return true
    }

    private func lockPiece() {
        guard let piece = currentPiece else { return }

        for (i, row) in piece.blocks.enumerated() {
            for (j, cell) in row.enumerated() where cell == 1 {
                let gridY = piece.y + i
                let gridX = piece.x + j
                if gridY >= 0 && gridY < rows && gridX >= 0 && gridX < cols {
                    grid[gridY][gridX] = piece.shape
                }
            }
        }
    }

    private func clearLines() {
        var linesToClear: [Int] = []

        for (index, row) in grid.enumerated() {
            if row.allSatisfy({ $0 != nil }) {
                linesToClear.append(index)
            }
        }

        if !linesToClear.isEmpty {
            for line in linesToClear.reversed() {
                grid.remove(at: line)
                grid.insert(Array(repeating: nil, count: cols), at: 0)
            }

            let cleared = linesToClear.count
            linesCleared += cleared
            score += cleared * 100 * level
            level = 1 + linesCleared / 10
            startTimer()
        }
    }
}
