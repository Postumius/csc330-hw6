require_relative './hw6provided'

class MyPieceChallenge < Piece
  All_Pieces = [[[[0, 0]]]]

   #returns number of squares in block
  def size
    @all_rotations[0].size
  end

   # class method to choose the next piece
  def self.next_piece (board)
    MyPieceChallenge.new(All_Pieces.sample, board)
  end

  def move_to_best
    dest = pick_spot(potential_spots)
    move(dest[0]-@base_position[0], dest[1]-@base_position[1], 0)
  end

  private
  def pick_spot (spots)
    max = [0, 0]
    spots.each do |point|
      if point[1] > max[1]
      then max = point     
      end
    end
    max
  end

  def potential_spots
    (0..@board.num_columns-1).map do |x|
      [x, lowest_fit(@all_rotations[0], x)]
    end
  end

  def fits? (shape, x, y)
    shape.each do |point|
      location = [point[0]+x, point[1]+y]
      if !@board.empty_at(location)
      then
        puts(point)
        return false
      end
    end
    return true
  end

  def lowest_fit(shape, x)
    (@board.num_rows-1).downto(0).each do |y|
      if fits?(shape, x, y)
      then return y
      end
    end
    raise("no fit in column")
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
