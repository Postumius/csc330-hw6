require_relative './hw6provided'

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def self.from_array(arr)
    Point.new(arr[0], arr[1])
  end

  def +(other)
    Point.new(self.x + other.x, self.y + other.y)
  end
end

class MyPieceChallenge < Piece
  #All_Pieces = [[[[-1, 0], [0, 0], [1, 0]],
   #              [[0, -1], [0, 0], [0, 1]]]]

  Up = [0, -1]
  Down = [0, 1]
  Left = [-1, 0]
  Right = [1, 0]
  
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
    #puts dest
    move(dest[0] - @base_position[0],
         dest[1] - @base_position[1],
         dest[2] - @rotation_index)
  end

  private
  def pick_position (positions)
    best = [0, 0, 0]
    max = -26
    positions.shuffle.each do |pos|
      score = h_reach_low(pos)/10 +              
              h_hug(pos)
              #h_dont_cover_holes(pos)
      if score > max
      then
        max = score
        best = pos
      end
    end
    #puts "----"
    #puts(h_reach_low(best))
    #puts(h_hug(best))
    
    best
  end

  #heuristics that we'll maximise
  def h_reach_low(pos)
    shape = shape_in_pos(pos)
    -@board.num_rows + 1 +
      lowest_extent(shape)
  end

  def h_hug(pos)
    shape = shape_in_pos(pos)
    is_empty = ->(pt){@board.empty_at(pt) && !shape.include?(pt)}
    score = 0
    cardinals = [Up, Down, Left, Right]
    shape.each do |point|
      cardinals.each do |dir|
        adj_point = plus(point, dir)
        if !@board.empty_at(adj_point)
        then score += 2
        elsif is_empty.(adj_point)
          if !leads_up?(adj_point, is_empty)
          then score -= 1
          end
        end
      end
    end
    score
  end

  def plus(arr1, arr2)
    arr1.zip(arr2).map{|x1, x2| x1+x2}
  end

  def leads_up?(point, empty_test)
    inner = ->(pt, dir) {
      if !empty_test.(pt)
      then false
      elsif empty_test.(plus(pt, Up))
      then true
      else
        inner.(plus(pt, dir), dir)
      end
    }
    inner.(point, Left) || inner.(point, Right)
  end
        
      
  def h_dont_cover_holes(pos)
    shape = shape_in_pos(pos)
    empty = ->(pt){@board.empty_at(pt) && !shape.include?(pt)}
    score = 0
    shape.each do |point|
      
      if empty.(below(point)) 
      then score -= 1
      end
    end
    score
  end


  def shape_in_pos(pos)
    @all_rotations[pos[2]].map do |point|
      plus(point, pos)
    end
  end 
  
  def lowest_extent(shape)
    lowest = 0
    shape.each do |point|
      if point[1] > lowest
      then lowest = point[1]
      end
    end
    lowest
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
      if fits?(shape.map{|point| plus(point, [x,y])})
      then return y
      end
    end
    puts("no fit in column")
    puts(x)
  end

  def fits? (shape)
    shape.each do |point|
      if !@board.empty_at(point)
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
