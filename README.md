# Lawn Bowling Scoring App

A modern Flutter application for scoring lawn bowling matches with URL parameter support for pre-configuring shot positions and scores.

## 📋 URL Parameters Guide

### Basic URL Structure
```
https://globallawnbowls.com/matlength/?player1Name=<name>&player2Name=<name>&currentEnd=<number>&totalEnds=<number>&player1Score=<number>&player2Score=<number>&p1_shots=<coordinates>&p2_shots=<coordinates>
```

### URL Parameters
| Parameter | Description | Example |
|-----------|-------------|---------|
| `player1Name` | Name of the first player | `player1Name=John` |
| `player2Name` | Name of the second player | `player2Name=Jane` |
| `currentEnd` | Current end number being played | `currentEnd=3` |
| `totalEnds` | Total number of ends in the game | `totalEnds=7` |
| `player1Score` | Current score of player 1 | `player1Score=10` |
| `player2Score` | Current score of player 2 | `player2Score=8` |
| `p1_shots` | Player 1's shot coordinates | `p1_shots=0.25,0.5;0.75,0.3` |
| `p2_shots` | Player 2's shot coordinates | `p2_shots=0.4,0.4;0.9,0.2` |

### Shot Data Format
Each player's shots are represented by coordinates separated by semicolons:
```
p1_shots=x1,y1;x2,y2;x3,y3
```
- Use comma (,) to separate x and y coordinates
- Use semicolon (;) to separate different shots
- Example: `p1_shots=0.25,0.5;0.75,0.3` represents two shots

Where:
- `x`: X-coordinate of the shot (-1.0 to 1.0)
- `y`: Y-coordinate of the shot (-1.0 to 1.0)
- `r`: Ring value (0-10)
- `|`: Separator between different shots

### Scoring Zones
| Zone | Score | Distance from Center |
|------------|-------|---------------------|
| Ring 0 (Inner) | 0 | 0.0 - 0.2 |
| Ring 1 | 1 | 0.2 - 0.4 |
| Ring 2 | 2 | 0.4 - 0.6 |
| Ring 3 | 3 | 0.6 - 0.8 |
| Ring 4 (Outer) | 4 | 0.8 - 1.0 |
| Ditch | Special Scoring* | > 1.0 |

*Ditch Scoring Rules:
- If the jack (target) is in the ditch, any bowl in the ditch that is within the rink boundaries and closer to the jack than any other bowl on the green scores points
- Bowls in the ditch are still "live" if they were touchers (touched the jack before entering the ditch)
- To mark a shot in the ditch, use coordinates beyond 1.0 (e.g., x=1.2, y=1.2)

### Coordinate System
- The target face uses a normalized coordinate system
- Center of the target is (0,0)
- Top edge is y = 1.0
- Bottom edge is y = -1.0
- Left edge is x = -1.0
- Right edge is x = 1.0

### Example URLs

1. Complete game state with multiple shots:
```
https://globallawnbowls.com/matlength/?player1Name=John&player2Name=Jane&currentEnd=3&totalEnds=7&player1Score=10&player2Score=8&p1_shots=0.1,0.1;0.3,0.3&p2_shots=0.5,0.5;0.7,0.7
```

2. Single shot in the inner ring (0 points):
```
p1_shots=0.1,0.1
```

3. Multiple shots in different rings:
```
p2_shots=0.3,0.3;0.7,0.7;0.9,0.9
```
(These shots would score 1, 3, and 4 points respectively)

4. Ditch shot scoring (toucher):
```
?shots=1.1,1.1,1
```

## 🎯 Shot Placement Examples

### Common Shot Positions
- Center shot: `x=0, y=0`
- Top of target: `x=0, y=1`
- Bottom of target: `x=0, y=-1`
- Left edge: `x=-1, y=0`
- Right edge: `x=1, y=0`

### Diagonal Positions
- Top-right: `x=0.707, y=0.707` (approximately 45 degrees)
- Top-left: `x=-0.707, y=0.707`
- Bottom-right: `x=0.707, y=-0.707`
- Bottom-left: `x=-0.707, y=-0.707`

## 📝 Notes
- Green coordinates are between -1.0 and 1.0
- Ditch shots use coordinates > 1.0
- Ring scoring goes from 0 (innermost) to 4 (outermost)
- Use `currentEnd` parameter to specify the current end (1 to totalEnds)
- `totalEnds` parameter sets the total number of ends in the game
- Player scores are tracked using `player1Score` and `player2Score`
- Multiple shots are separated by semicolons (;) within each player's shots
- Coordinates for each shot are separated by comma (,)
- Each player's shots are tracked separately using `p1_shots` and `p2_shots`
- Invalid coordinates on the green will be treated as ditch shots
- Ditch shots must be marked with appropriate coordinates (>1.0)

## 🔍 Validation
The app automatically validates:
- Green coordinates (-1.0 to 1.0)
- Ditch coordinates (>1.0)
- Current end number (must be ≤ totalEnds)
- Player names (non-empty strings)
- Score values (non-negative integers)
- Shot coordinate format (x,y pairs)
- Multiple shot separator format (semicolon)
- URL parameter completeness and format

## 🚀 Quick Start
1. Open the app with default settings:
```
https://your-app-url.com/
```

2. Load specific shots for end 3:
```
https://your-app-url.com/?shots=0,0,10|0.1,0.1,9|0.3,0,8&end=3
```

3. Practice mode with single shot:
```
https://your-app-url.com/?shots=0.5,0.5,5
```
