# Tetris for visionOS - Design Document

## Technical Overview

This document provides information about the technical implementation of Tetris for visionOS.

### High-Level Structure

The application follows a modern SwiftUI + RealityKit architecture with clear separation of concerns:

1. **App Layer** (`tetrisApp.swift`): Manages window configuration and app lifecycle
2. **View Layer** (`ContentView.swift`, `CombinedGameView.swift`, `GameBoardOnlyView.swift`): User interface and visual presentation
3. **Game Logic Layer** (`GameManager.swift`): Core Tetris mechanics and state management
4. **Rendering Layer** (RealityKit in `GameBoardOnlyView.swift`): 3D visualization

## Core Components

### 1. TetrisGameManager (`GameManager.swift`)

**Purpose**: Central state management and game logic controller.

**Key Design Decisions**:

- **ObservableObject Pattern**: Using `@MainActor` and `ObservableObject` ensures all UI updates happen on the main thread, preventing race conditions in visionOS's concurrent environment.

- **Grid Representation**: The game grid is a 2D array `[[TetrisShape?]]` of 20 rows × 10 columns. We chose optional `TetrisShape` enum values rather than integers to maintain type safety and make the code more readable. A `nil` value represents an empty cell, while a `.some(TetrisShape)` represents a locked block.

- **Piece Structure**: Each `TetrisPiece` contains:
  - `shape: TetrisShape` - The piece type (I, O, T, S, Z, J, L)
  - `blocks: [[Int]]` - The actual block pattern (2D array of 0s and 1s)
  - `x, y: Int` - Top-left position in the grid
  
  This separation allows us to rotate pieces by transforming the `blocks` array without affecting position.

- **Rotation Algorithm**: We implement clockwise rotation using matrix transposition:
  ```swift
  rotated[j][rows - 1 - i] = blocks[i][j]
  ```
  This transforms each element from position (i, j) to (j, rows-1-i), achieving a 90° clockwise rotation. We chose this over storing pre-defined rotations to reduce memory footprint and code duplication.

- **Collision Detection**: The `isValidPosition()` method checks three conditions:
  1. Piece doesn't exceed left/right boundaries
  2. Piece doesn't exceed bottom boundary
  3. Piece doesn't overlap with locked blocks
  
  We check these before any move/rotation, allowing the move only if all conditions pass.

- **Timer-Based Gravity**: Using `Timer.scheduledTimer` for automatic downward movement creates the classic Tetris "gravity" effect. The interval decreases with level: `max(0.1, 1.0 - Double(level - 1) * 0.1)`, providing progressive difficulty. We cap the minimum at 0.1 seconds to maintain playability.

**Why Not SpriteKit/GameplayKit?**: While these frameworks offer game-specific features, we chose a pure SwiftUI + RealityKit approach to leverage visionOS's spatial computing capabilities. RealityKit's 3D rendering provides a more immersive experience than 2D sprites.

### 2. GameBoardOnlyView (`GameBoardOnlyView.swift`)

**Purpose**: 3D visualization and gesture handling for the game board.

**Key Design Decisions**:

- **RealityView**: We use SwiftUI's `RealityView` to embed RealityKit content directly in the SwiftUI view hierarchy. This provides automatic lifecycle management and seamless integration with SwiftUI's reactive system.

- **Board Construction**: The game board consists of:
  - **Back Panel**: A dark blue rectangle providing visual context and depth
  - **Grid Lines**: 31 individual `ModelEntity` objects (11 vertical + 20 horizontal) created programmatically. While we could have used a single textured plane, individual lines allow for dynamic styling and future animations.
  - **Game Blocks**: Each block is a rounded cube (`generateBox` with `cornerRadius`) with metallic material for a modern aesthetic.

- **Lighting System**: Three point lights provide depth perception:
  - Primary light (intensity 10000) from the front
  - Two secondary lights (intensity 5000) from the sides
  This three-point lighting setup ensures blocks cast appropriate shadows and appear three-dimensional.

- **Update Strategy**: The `update:` closure recreates all game blocks on every state change. While less efficient than differential updates, this approach:
  - Simplifies state synchronization
  - Prevents orphaned entities
  - Ensures the view always matches game state
  - Performance impact is negligible (20×10 grid = max 200 blocks)

- **Gesture Handling**:
  
  **Tap vs Double-Tap Detection**: We implement custom double-tap detection because `SpatialTapGesture` doesn't provide this natively:
  ```swift
  if timeSinceLastTap < 0.2 && tapCount == 1 {
      // Double tap
  } else {
      // Single tap (with 0.2s delay to detect potential double tap)
  }
  ```
  This requires a 200ms delay before confirming a single tap, which is acceptable for gameplay.

  **Drag Gesture Thresholds**: We require 100-pixel horizontal movement before registering a move. This prevents accidental movements from small hand jitters. Additionally, we enforce a 0.2-second cooldown between moves to prevent pieces from moving too rapidly.

**Why Not Use Collision Components for Gameplay?**: RealityKit's collision system is designed for physics simulation. We use it only for visual interaction (making current piece blocks "interactive") but handle all game logic collision detection manually in `GameManager`. This separation keeps game logic deterministic and independent of the physics engine.

### 3. CombinedGameView (`CombinedGameView.swift`)

**Purpose**: Orchestrates the complete game interface including board, controls, and UI elements.

**Key Design Decisions**:

- **Single Window Approach**: Initially, we considered separate windows for the board and controls, but merged them to:
  - Reduce cognitive load (one window to manage)
  - Simplify window lifecycle management
  - Ensure controls are always accessible
  - Match user expectations from traditional gaming UIs

- **Score Display Architecture**: The top bar uses `HStack` with fixed spacing and separators. Each stat (Score/Level/Lines) is a `VStack` with the value above the label. This creates visual hierarchy and makes numbers the focus.

- **Control Button Layout**: We positioned buttons in a row rather than a grid because:
  - Single row is easier to reach in VR space
  - Left-to-Right ordering matches Western reading patterns
  - Reduces vertical space usage, allowing more room for the game board

- **Game Over Overlay Design**: After several iterations, we settled on a **ZStack overlay approach**:
  
  **Evolution of Game Over Screen**:
  1. **Initial**: Added to VStack, causing layout shift
  2. **Second attempt**: Used `.overlay` with z-offsets, but positioning was unreliable
  3. **Final solution**: Full-screen ZStack with centered card
  
  The current implementation:
  - Uses `Color.black.opacity(0.7)` backdrop to dim the game
  - Centers a compact card (320px max width) with all stats
  - Remains clickable through `.allowsHitTesting(true)`
  - Appears/disappears with scale + opacity animation
  
  This approach ensures the game over screen is always visible, clickable, and doesn't affect the underlying layout.

- **Window Management**: We use explicit window IDs (`"MenuWindow"`, `"GameWindow"`) and `@Environment(\.openWindow)` / `dismissWindow()` for precise window control:
  
  ```swift
  openWindow(id: "GameWindow")
  dismissWindow()  // Closes current window
  ```
  
  **Why dismiss current window without ID?**: In visionOS, calling `dismissWindow()` from within a view dismisses that view's window. This is more reliable than using `dismissWindow(id:)` which sometimes failed to close the correct window.

### 4. ContentView (Main Menu)

**Purpose**: Entry point and main menu interface.

**Key Design Decisions**:

- **Visual Design**: Gradient background (blue → purple) with a large centered logo creates a welcoming entry point. The gradient is softer than the game window's dark background, establishing visual hierarchy.

- **State-Aware UI**: The menu displays different content based on `gameManager.isPlaying`:
  - Not playing: Shows "Start Game" button and controls instructions
  - Playing: Shows "Game in Progress" with current stats
  
  This prevents users from accidentally starting multiple games and provides context about existing game state.

- **Window Transition Logic**:
  ```swift
  openWindow(id: "GameWindow")
  gameManager.startGame()
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      dismissWindow(id: "MenuWindow")
  }
  ```
  
  The 0.3-second delay allows the game window to appear before the menu closes, preventing a jarring "flash of empty space." This timing was chosen after user testing.

### 5. Window Configuration (`tetrisApp.swift`)

**Purpose**: Define app structure and window properties.

**Key Design Decisions**:

- **Two WindowGroups**: We use separate `WindowGroup` declarations for menu and game rather than conditional logic within a single group. This allows independent styling and sizing.

- **Window Styles**:
  - Menu: `.windowStyle(.plain)` with pixel dimensions (800×600)
  - Game: `.windowStyle(.volumetric)` with meter dimensions (0.6×1.3×0.4m)
  
  **Why different styles?**: The menu is a traditional 2D interface, while the game benefits from volumetric presentation to showcase the 3D board. Volumetric windows also support depth perception through z-positioning.

- **Default Sizes**: The game window size (0.6m wide, 1.3m tall) was chosen through iteration:
  - 0.6m width: Comfortable viewing distance in VR space
  - 1.3m height: Accommodates board (0.8m) + controls + padding
  - 0.4m depth: Sufficient for z-offset effects without overwhelming space

## Future Enhancements

Based on the current architecture, these features could be added:

1. **Next Piece Preview**: Add a small side window showing the next piece
2. **High Score Persistence**: Use UserDefaults or CloudKit
3. **Power-ups**: Extend `TetrisShape` enum with special pieces
4. **Themes**: Move colors to a separate theme system
5. **Sound**: Add spatial audio using RealityKit's audio system
6. **Haptics**: Add haptic feedback for piece locking (Vision Pro has no built-in haptics, but could use audio cues)
