# encoding: utf-8

class Chessboard
  attr_accessor :board, :killed_piece

  def initialize
    create_board
  end

  def [](coords)
    board[coords]
  end

  def create_board
    self.board = Hash.new

    8.times do |y|
      case y
      when 1
        8.times { |x| board[[x, y]] = Pawn.new("W", self) }
      when 6
        8.times { |x| board[[x, y]] = Pawn.new("B", self) }
      when 0
        8.times { |x| board[[x, y]] = make_piece(x, "W") }
      when 7
        8.times { |x| board[[x, y]] = make_piece(x, "B") }
      else
        8.times { |x| board[[x, y]] = NilPiece.new }
      end
    end
  end

  def make_piece(column, color)
    case column
    when 0, 7 then return Castle.new(color, self)
    when 1, 6 then return Knight.new(color, self)
    when 2, 5 then return Bishop.new(color, self)
    when 3 then return Queen.new(color, self)
    when 4 then return King.new(color, self)
    end
  end

  def update(move)
    # Saves the killed piece for undoing later
    self.killed_piece = NilPiece.new
    from, to = move

    self.killed_piece = board[to] unless board[to].class == "NilPiece"
    board[to] = board[from]
    board[from] = NilPiece.new
  end

  def undo_move(move)
    # for hypothetical checking purposes
    to, from = move
    board[to] = board[from]
    board[from] = killed_piece
  end

  def in_check?(color)
    check = false
    opp_color = (['B', 'W'] - [color])[0]

    king = color == "W" ? "♔" : "♚"
    king_loc = board.select { |location, piece| piece.name == king}.keys[0]

    board.each do |location, piece|
      next unless piece.color == opp_color
      check = true if piece.possible_moves(location).include?(king_loc)
    end

    check
  end

  def test_for_check(color, move)
    update(move)
    in_check?(color)
    undo_move(move)
  end

  def checkmate?(color)
    return false unless in_check?(color)
    checkmate = true
    board.dup.each do |location, piece|
      next unless piece.color == color
      piece.possible_moves(location).each do |move_to|
        checkmate = false unless test_for_check(color, [location,move_to])
      end
    end
    #goes through all possible moves and uses check
    checkmate
  end

  def print_board
    #prints board
    header = ("A".."H").map(&:to_s).map { |char| char }
    y_axis = ("1".."8").map { |char| char }

    puts " #{header.join}".center(40)

    7.downto(0) do |y|

      row = ["#{y_axis[y]}"]
      8.times do |x|
        piece = board[[x,y]].name
        row << ((x + y).even? ? piece : piece.on_green)
        # row << "|"
      end

      row << "#{y_axis[y]}"

      puts row.join.center(96)
    end

    puts " #{header.join}".center(40)
  end

  def get_piece_moves(coordinates)
    piece = board[coordinates]
    piece.possible_moves(coordinates)
  end

  def get_piece(coordinates)
    board[coordinates]
  end
end