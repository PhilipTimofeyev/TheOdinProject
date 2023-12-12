# Knights Travails

Knights Travails is a ruby script that finds and returns the shortest path between two squares on a chess board. Created as part of the Odin Project's curriculum. 

The script creates and displays a chess board that is a marked with an `S` for the starting square and `E` for the ending square. Although the board defaults to a standard 8x8 chess board, it can be changed to any size by modifying the `UPPER_BOUND` constant in the `Chessboard` class.

The script builds a complete chessboard with each square being a node with four values:

- An [x, y] coordinate to denote where the square is on the board.
- The adjacent squares (which only get filled in when the `knight_travails` method is run)
- A boolean value for whether the square has been visited.
- A string denoting the design of the square. All squares are built with a default `_` string to express a visually empty square.

When the `knight_travails` method is run, it continously creates an array of adjacent legal squares and searches through them using breadth first search. Since the structure is an unweighted graph, it uses a modified version of BFS where it stores the predecessor of a given node while executing the search. This gives it a time complexity of O(V+E).

The `Knight` class contains the moveset for a standard knight in chess. The `knight_moves` method can be used with any other chess piece as long as it contains a `moveset` method which returns an array of all possible squares the piece can move to given a current square. This OOP approach was done to make expanding the program into handling other chess pieces with different movesets simple.

## Installation

Simply run the script in terminal:

```bash
ruby /knight_travails.rb
```

## Usage

Simply modifiy the coordinates in the `knight_moves` method on `line 143` to any [x, y] coordinate that is within the boundaries of the chessboard (between [0, 0] and [7, 7]). 

```python
knight_moves([0, 0], [7, 7])
#returns You made it in 6 moves! Here's your path:
#[0, 0]
#[1, 2]
#[2, 0]
#[3, 2]
#[4, 4]
#[5, 6]
#[7, 7]
```

## License

[GNU](https://choosealicense.com/licenses/gpl-3.0/)
