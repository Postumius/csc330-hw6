# Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in,
# so do not modify the other files as
# part of your solution.

class MyPiece < Piece
  # The constant All_My_Pieces should be declared here:
  All_My_Pieces =
    [[[[0, 0], [1, 0], [0, 1], [1, 1]]],  # square (only needs one)
     rotations([[0, 0], [-1, 0], [1, 0], [0, -1]]), # T
     [[[0, 0], [-1, 0], [1, 0], [2, 0]], # long (only needs two)
      [[0, 0], [0, -1], [0, 1], [0, 2]]],
     rotations([[0, 0], [0, -1], [0, 1], [1, 1]]), # L
     rotations([[0, 0], [0, -1], [0, 1], [-1, 1]]), # inverted L
     rotations([[0, 0], [-1, 0], [0, -1], [1, -1]]), # S
     rotations([[0, 0], [1, 0], [0, -1], [-1, -1]]), # Z
     [[[0, 0], [-1, 0], [-2,0], [1, 0], [2, 0]], # longer (only needs two)
      [[0, 0], [0, -1], [0,-2], [0, 1], [0, 2]]], 
     rotations([[0, 0], [0, 1], [1, 1]]), # corner
     rotations([[0, 0], [1, 0], [0, -1], [-1, -1], [1, -1]])] # weird thing

  # Your Enhancements here

  #returns number of squares in block
  def size
    @all_rotations[0].size
  end

  # class method to choose the next piece
  def self.next_piece (board)
    MyPiece.new(All_My_Pieces.sample, board)
  end

  def self.cheat_piece (board)
    MyPiece.new([[0]], board)
  end
  
end

class MyBoard < Board
  # Your Enhancements here:
  def initialize (game)
    super(game)
    @cheat_next = false
    @current_block = MyPiece.next_piece(self)
  end

  def cheat    
    if @score >= 100 && !@cheat_next
    then
      @score -= 100
      @game.update_score
    end
    @cheat_next = true
      
  end

  # gets the next piece
  def next_piece
    @current_block =
      if @cheat_next
      then MyPiece.cheat_piece(self)
      else MyPiece.next_piece(self)
      end
    @current_pos = nil
    @cheat_next = false
  end

  # gets the information from the current piece about where it is and uses this
  # to store the piece on the board itself.  Then calls remove_filled.
  #accounts for variable block size
  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0..@current_block.size-1).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end
  
end

class MyTetris < Tetris
  # Your Enhancements here:
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  def key_bindings
    super
    @root.bind('u' , proc do
                 @board.rotate_clockwise
                 @board.rotate_clockwise
               end) 
    @root.bind('c' , proc {@board.cheat})
  end  

end

