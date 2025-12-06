# Tetris for visionOS

A fully-featured 3D Tetris game built specifically for Apple Vision Pro. This app adds immersive spatial computing and interaction to the iconic Tetris game.

## Overview

This project is an implementation of Tetris designed for visionOS. It includes a 3D game board and spatial hand gesture controls in a SwiftUI interface.

## Requirements

- **Apple Vision Pro** or **visionOS Simulator** (requires macOS 14.0 or later with Xcode 15.2+)
- **Xcode 15.2** or later
- **visionOS 2.1** SDK or later

## Installation & Setup

### 1. Opening the Project

1. Launch Xcode
2. Select **File → Open**
3. Navigate to the project folder and select the `.xcodeproj` file
4. Wait for Xcode to index the project

### 2. Configuring the Target

1. In Xcode, select the project in the navigator (blue icon at the top)
2. Under **Targets**, select the Tetris target
3. In the **Signing & Capabilities** tab:
   - Select your development team from the dropdown
   - Xcode will automatically generate a bundle identifier

### 3. Running the Project

**Option A: Using the Simulator (Recommended for Testing)**
1. In the top toolbar, select the destination dropdown (next to the Play button)
2. Choose **Apple Vision Pro** from the simulator options
3. Click the **Play** button (▶) or press `Cmd+R`
4. The simulator will launch and display the app

**Option B: Using a Physical Apple Vision Pro**
1. Connect your Vision Pro to your Mac via USB-C
2. Enable Developer Mode on your Vision Pro (Settings → Privacy & Security → Developer Mode)
3. Select your Vision Pro from the destination dropdown
4. Click the **Play** button (▶) or press `Cmd+R`
5. The app will install and launch on your device

## How to Play

### Starting a Game

1. When you launch the app, you'll see the **main menu window** with:
   - The TETRIS title and logo
   - A "Start Game" button
   - Control instructions
2. Click **"Start Game"**
3. The menu window will close and the **game window** will open
4. The game window contains:
   - A 3D volumetric game board showing the Tetris grid
   - Score, Level, and Lines statistics at the top
   - Four control buttons at the bottom (LEFT, RIGHT, ROTATE, DROP)
   - A pause button in the top-right corner

### Game Controls

You have **two ways** to control the game:

#### Method 1: Spatial Hand Gestures (Recommended)
Look at the game board and use these gestures:

- **Single Tap**: Rotate the current piece clockwise
- **Double Tap**: Drop the piece immediately to the bottom
- **Drag Left/Right**: Move the piece horizontally (requires 100-pixel movement threshold)

These gestures work anywhere on the game board - you don't need to precisely tap on the falling piece.

#### Method 2: On-Screen Buttons
Use the four buttons at the bottom of the window:

- **LEFT** (Blue): Move piece left one column
- **RIGHT** (Blue): Move piece right one column  
- **ROTATE** (Purple): Rotate piece clockwise
- **DROP** (Cyan): Instantly drop piece to the bottom

### Gameplay Mechanics

1. **Objective**: Clear horizontal lines by filling them completely with blocks
2. **Scoring**:
   - Each cleared line: 100 points × current level
   - Multiple lines cleared simultaneously multiply the score
3. **Leveling**:
   - Every 10 lines cleared increases your level by 1
   - Higher levels increase the game speed (pieces fall faster)
4. **Game Over**: When a new piece cannot spawn at the top of the board

### Pausing the Game

1. Click the **pause button** (⏸️) in the top-right of the score display
2. A dialog will appear with three options:
   - **Resume**: Continue playing
   - **End Game**: Return to the main menu and close the game window
   - **Cancel**: Close the dialog and remain paused

### Game Over

When the game ends:
1. A **Game Over card** appears in the center of the screen showing:
   - "GAME OVER" title with gradient effect
   - Your final score (large display)
   - Level reached and total lines cleared
2. Click **"PLAY AGAIN"** to immediately start a new game
3. Or click the **pause button** and select **"End Game"** to return to the main menu

### Returning to Main Menu

From the game window:
1. Click the **pause button** (⏸️)
2. Select **"End Game"**
3. The game window will close
4. The main menu window will reopen
5. From there, you can start a new game

## Troubleshooting

### Game Window Not Appearing
- **Solution**: Check that the simulator or device is running properly. Try stopping and rerunning the app.

### Gestures Not Working
- **Issue**: Hand gestures may not register in the simulator
- **Solution**: Use the on-screen control buttons instead, or test on a physical Vision Pro

### Multiple Game Windows Open
- **Issue**: If you see multiple game windows stacked up
- **Solution**: This was a bug in earlier versions. Make sure you're using the latest code. To fix: Close all windows, then restart the app.

### Play Again Button Not Responding
- **Solution**: The button should be fully clickable. If it's not responding, try clicking directly on the text "PLAY AGAIN" rather than the surrounding area.

### Game Too Fast/Slow
- The speed automatically increases with level (every 10 lines cleared)
- Speed formula: `max(0.1, 1.0 - (level - 1) × 0.1)` seconds per drop
- This is intentional game design and cannot be adjusted during gameplay

## Features

- Classic Tetris gameplay with all 7 standard pieces (I, O, T, S, Z, J, L)  
- 3D volumetric game board using RealityKit  
- Spatial hand gesture controls (tap, double-tap, drag)  
- Traditional button controls for accessibility  
- Progressive difficulty (speed increases with level)  
- Score tracking and statistics display  
- Pause/resume functionality  
- Polished game over screen with statistics  
- Clean window management (menu ↔ game transitions)  
- Smooth animations and visual effects  

## Known Limitations

- Gesture controls work best on physical Vision Pro hardware; simulator support is limited
- No multiplayer functionality
- No "next piece" preview (can be added in future versions)
- No high score persistence (scores reset when app closes)
- Window positioning is automatic; cannot be manually adjusted during gameplay

## Tips for Best Experience

1. **Use spatial gestures** for the most immersive experience on physical hardware
2. **Start slow**: Get comfortable with the controls before the game speeds up
3. **Strategic dropping**: Use double-tap/DROP to quickly place pieces and think about your next move
4. **Position your view**: You can move and rotate the game window in your space for the most comfortable viewing angle
5. **Pause liberally**: Don't hesitate to pause and take breaks - the game will wait

## Credits

Developed for visionOS using SwiftUI and RealityKit. Classic Tetris gameplay mechanics remain timeless.

## Support

If you encounter issues:
1. Restart the application
2. Clean build folder in Xcode (Product → Clean Build Folder)
3. Delete derived data
4. Rebuild and run

For development questions, refer to DESIGN.md for technical implementation details.
