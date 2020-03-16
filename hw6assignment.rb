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
      @cheat_next = true
    end

      
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




class MyPieceChallenge < Piece
  
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
    move(dest[0] - @base_position[0],
         dest[1] - @base_position[1],
         dest[2] - @rotation_index)
  end
  

  private
  
  #maximizes the heuristics to find the best position
  def pick_position (positions)
    positions.shuffle #shuffle first to avoid always picking leftmost maximum
      .reduce do |p1, p2|
      if combine_heur(p1) > combine_heur(p2)
      then p1
      else p2
      end
    end
  end

  #weight heuristics individually
  def combine_heur(pos)
    (h_reach_low(pos)/5) + 
      h_hug(pos) +
      h_dont_cover_holes(pos) +
      h_clear_rows(pos)*2
  end
  

  ###### Heuristics Start Here #####

  #tries to get the lowest point on the block as low as possible
  def h_reach_low(pos)
    shape = shape_in_pos(pos)
    -@board.num_rows + 1 +
      lowest_extent(shape)
  end 

  #tries to place blocks to there isn't empy space below them
  def h_dont_cover_holes(pos)
    shape = shape_in_pos(pos)    
    is_empty = make_empty_test(shape_in_pos(pos))
    shape.reduce(0) do |score, point|      
      if is_empty.(plus(point, Down)) 
      then score-1
      else score
      end
    end
  end

  #tries to complete rows
  def h_clear_rows(pos)
    shape = shape_in_pos(pos)
    is_empty = make_empty_test(shape)
    shape.reduce(0) do |score, point|
      if (0..9).zip(Array.new(10,point[1])).
           all?{|pt| !is_empty.(pt)}
      then score + 1
      else score
      end
    end
  end
  
  #tries to maximise the perimeter that is touching other blocks
  #tries to avoid creating "air bubbles" i.e. empty space that
  #doesn't lead up
  def h_hug(pos)
    shape = shape_in_pos(pos)
    is_empty = make_empty_test(shape)
    #score = 0
    cardinals = [Up, Down, Left, Right]
    shape.reduce(0) do |scr, point|
      cardinals.reduce(0) do |score, dir|
        adj_point = plus(point, dir)
        if !@board.empty_at(adj_point)
        then score + 2
        elsif is_empty.(adj_point) &&
              !leads_up?(adj_point, is_empty, 2)
        then score - 1
        else score
        end
      end + scr
    end
  end

  ##### Heuristics End Here #####

  #tests if a space will be empty once the shape has been placed
  def make_empty_test(shape)
    ->(pt){@board.empty_at(pt) && !shape.include?(pt)}
  end

  
  #directions to be added to a point to move it
  Up = [0, -1]
  Down = [0, 1]
  Left = [-1, 0]
  Right = [1, 0]

  #elementwise addition
  def plus(arr1, arr2)
    arr1.zip(arr2).map{|x1, x2| x1+x2}
  end

  #follows an air bubble upwards
  #returns true if the bubble extends upwards by the given height
  def leads_up?(point, empty_test, height)
    inner = ->(pt, dir) { #inner searches either left or right
      if !empty_test.(pt)
      then false
      elsif point[1] == 0 #if it hits the top of the board
      then true
      elsif height == 0   #if it has risen enough
      then true
      elsif empty_test.(plus(pt, Up)) 
      then leads_up?(plus(pt, Up), empty_test, height-1) #move up a level
      else
        inner.(plus(pt, dir), dir) #move sideways and keep looking
      end
    }
    inner.(point, Left) || inner.(point, Right)
  end 

  #translates the shape into the right position
  def shape_in_pos(pos)
    @all_rotations[pos[2]].map do |point|
      plus(point, pos)
    end
  end 

  #locates the lowest square on the shape
  def lowest_extent(shape)
    lowest = 0
    shape.each do |point|
      if point[1] > lowest
      then lowest = point[1]
      end
    end
    lowest
  end
  

  ##### functions for finding all possible positions start here #####

  #locates left and rightmost squares
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
    [left, right]
  end

  #for every rotation and every column in which it fits,
  #finds the lowest resting position for the shape
  def potential_positions
    (0...@all_rotations.size).map do |rot_index|
      shape = @all_rotations[rot_index]
      extent = horiz_extent(shape)
      (0-extent[0]...@board.num_columns-extent[1]).map do |x|
        [x, lowest_fit(shape, x), rot_index]
      end
    end.reduce(:+)
  end    
  
  #given a column, finds the lowest y position into which
  #the shape can fit
  def lowest_fit(shape, x)
    (@board.num_rows-1).downto(0).each do |y|
      if leads_up?([x,y], fits?(shape), 5) #prevent the program from teleporting shapes to impossible positions
      then return y
      end
    end
    0
  end

  #tests if the shape fits in position delta
  def fits? (shape)
    ->(delta) {
      shape.each do |point|
        if !@board.empty_at(plus(point, delta))
        then
          return false
        end
      end
      return true
    }
  end

   ##### functions for finding all possible positions end here #####  
end

class MyBoardChallenge < Board  
  def initialize (game)
    super(game)
    @current_block = MyPieceChallenge.next_piece(self)
    @auto_used = false
  end

  def auto
    if !game_over? and @game.is_running? and !@auto_used
      @current_block.move_to_best
    end
    @auto_used = true
    draw
  end

  # gets the next piece
  def next_piece
    @current_block = MyPieceChallenge.next_piece(self)
    @current_pos = nil
    @auto_used = false
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
