require_relative './hw6provided'

class MyPieceChallenge < Piece
  All_Pieces = [[[[0, 0]]]]

   # class method to choose the next piece
  def self.next_piece (board)
    Piece.new(All_Pieces.sample, board)
  end

  def move_to_best
    dest = pick_spot(potential_spots)
    move(dest[0]-@base_position[0], dest[1]-@base_position[1], 0)
  end

  private
  def pick_spot (spots)
    spots.each do |point|
      if point[1] > -1
      then return point
      end
    end
  end

  def potential_spots
    (0..@board.num_collumns).each do |x|
      [x, lowest_fit(@all_rotations[0], x)]
    end
  end

  def fits? (shape, x, y)
    shape.each do |point|
      if !board.empty_at(point)
      then return false
      end
    end
    return true
  end

  def lowest_fit(shape, x)
    (num_rows..0).each do |y|
      if fits?(shape, x, y)
      then return y
      end
    end
    -1
  end
  
end

class MyBoardChallenge < Board  
  def initialize (game)
    super(game)
    @current_block = MyPieceChallenge.next_piece(self)
  end

  # gets the next piece
  def next_piece
    @current_block = Piece.next_piece(self)
    @current_pos = nil
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
end
