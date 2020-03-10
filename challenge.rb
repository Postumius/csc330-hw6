require_relative './hw6provided'

class MyPieceChallenge < Piece
  All_Pieces = [[[[-1, 0], [0, 0], [1, 0]],
                 [[0, -1], [0, 0], [0, 1]]]]

  
   #returns number of squares in block
  def size
    @all_rotations[0].size
  end

   # class method to choose the next piece
  def self.next_piece (board)
    MyPieceChallenge.new(All_Pieces.sample, board)
  end

  def move_to_best
    dest = pick_position(potential_positions)
    puts dest
    move(dest[0] - @base_position[0],
         dest[1] - @base_position[1],
         dest[2] - @rotation_index)
  end

  private
  def pick_position (positions)
    max = [0, 0, 0]
    positions.each do |pos|
      if pos[1] > max[1]
      then max = pos
      end
    end
    max
  end

  def potential_positions
    (0...@all_rotations.size).map do |rot_index|
      shape = @all_rotations[rot_index]
      extent = horiz_extent(shape)
      (0-extent[0]...@board.num_columns-extent[1]).map do |x|
        [x, lowest_fit(shape, x), rot_index]
      end
    end.reduce(:+)
  end  

  def horiz_extent(shape)
    left = 0
    right = 0
    shape.each do |point|
      if point[0] < left
      then left = point[0]
      elsif right < point[0]
      then right = point[0]
      end
    end
    #puts [left, right]
    [left, right]
  end

   def lowest_fit(shape, x)
    (@board.num_rows-1).downto(0).each do |y|
      if fits?(shape, x, y)
      then return y
      end
    end
    puts("no fit in column")
    puts(x)
  end

  def fits? (shape, x, y)
    shape.each do |point|
      location = [point[0]+x, point[1]+y]
      if !@board.empty_at(location)
      then
        return false
      end
    end
    return true
  end

 
  
end

class MyBoardChallenge < Board  
  def initialize (game)
    super(game)
    @current_block = MyPieceChallenge.next_piece(self)
  end

  def auto
    if !game_over? and @game.is_running?
      @current_block.move_to_best
    end
    draw
  end

  # gets the next piece
  def next_piece
    @current_block = MyPieceChallenge.next_piece(self)
    @current_pos = nil
  end

 

  # gets the information from the current piece about where it is and uses this
  # to store the piece on the board itself.  Then calls remove_filled.
  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0...@current_block.size).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end
  
end

class MyTetrisChallenge < Tetris
   def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoardChallenge.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
   end

   def key_bindings
     super
     @root.bind('a' , proc {@board.auto})
   end  
   
end
