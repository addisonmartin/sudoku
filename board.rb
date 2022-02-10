class Board

  BOARD_SIZE = 9

  attr_accessor :box_size, :row_indicies, :col_indicies, :box_indicies

  # Internally store the puzzle board's state as a 1 dimensional array of length (BOARD_SIZE * BOARD_SIZE).
  attr_accessor :cells

  def initialize(args={})
    if BOARD_SIZE == 4
      @box_size = 2
    elsif BOARD_SIZE == 9
      @box_size = 3
    elsif BOARD_SIZE == 16
      @box_size = 4
    elsif BOARD_SIZE == 25
      @box_size = 5
    elsif BOARD_SIZE == 100
      @box_size = 10
    else
      raise ArgumentError.new("Board Size (#{BOARD_SIZE}) cannot be solved using this program!")
    end
    @box_size.freeze

    @row_indicies = []
    (0...BOARD_SIZE).each do |i|
      @row_indicies << Array((i * BOARD_SIZE)...((i+1) * BOARD_SIZE))
    end
    @row_indicies.freeze

    @col_indicies = []
    (0...BOARD_SIZE).each do |i|
      indicies = []
      (0...BOARD_SIZE).each do |j|
        indicies << i + (j * BOARD_SIZE)
      end

      @col_indicies << indicies
    end
    @col_indicies.freeze
    
    @box_indicies = []
    (0...@box_size).each do |i|
      (0...@box_size).each do |j|
        
        indicies = []

        (0...@box_size).each do |k|
          (0...@box_size).each do |l|
            indicies << ((i * @box_size) * BOARD_SIZE) + (j * @box_size) + (k * BOARD_SIZE) + l
          end
        end

        @box_indicies << indicies
      end
    end
    @box_indicies.freeze

    @cells = Array.new(BOARD_SIZE * BOARD_SIZE, '*')
    
    if args.is_a? String
      if File.exist?(args)
        board_file = File.open(args)
        board_data = board_file.read
        board_file.close

        create_from_string(board_data)
      end
    end

    raise RuntimeError.new("Board created with invalid initial state!") unless valid?
  end

  # Assumes the string contains numbers 1-9, *, and whitespace only. Each line separated by a \n and each cell with a single space.
  def create_from_string(board_string)
    board_string.split("\n").each_with_index do |board_line, col|
      row = 0
      board_line.split(" ").each do |cell_data|
        index = col * BOARD_SIZE + row
        
        if cell_data == "*"
          @cells[index] = "*"
        else
          cell = Integer(cell_data)
          @cells[index] = cell
        end

        row += 1
      end
    end
  end
  
  def to_s
    result = "+"

    (0...@box_size).each do
      result += "-" * ((2 * @box_size) + 1)
      result += "+"
    end

    (0...BOARD_SIZE).each do |row|
      result += "\n|"
      (0...BOARD_SIZE).each do |col|
        result += " #{@cells[(row * BOARD_SIZE) + col]}"

        if (col + 1) % @box_size == 0
          result += " |"
        end
      end

      if row == (BOARD_SIZE - 1)
        result += "\n+"
        (0...@box_size).each do |i|
          result += "-" * ((2 * @box_size) + 1)
          result += "+"
        end
      elsif (row + 1) % @box_size == 0
        result += "\n|"
        (0...@box_size).each do |i|
          result += "-" * ((2 * @box_size) + 1)
          
          if i == (@box_size - 1)
            result += "|"
          else
            result += "+"
          end
        end
      end
    end

    result
  end

  def rows
    all_rows = []

    @row_indicies.each do |row_index|
      row = []
      row_index.each do |index|
        row << @cells[index] unless @cells[index] == "*"
      end

      all_rows << row
    end

    return all_rows
  end

  def cols
    all_cols = []

    @col_indicies.each do |col_index|
      col = []
      col_index.each do |index|
        col << @cells[index] unless @cells[index] == "*"
      end

      all_cols << col
    end

    return all_cols
  end

  def boxes
    all_boxes = []

    @box_indicies.each do |box_index|
      box = []
      box_index.each do |index|
        box << @cells[index] unless @cells[index] == "*"
      end

      all_boxes << box
    end

    return all_boxes
  end

  # Returns the entire row of indicies that contain the given cellIndex.
  def row_indicies_for_cell_index(cellIndex)
    raise ArgumentError.new("Cell Index (#{cellIndex}) out of range!") if cellIndex < 0 or cellIndex >= (BOARD_SIZE * BOARD_SIZE)

    @row_indicies.each do |row_index|
      return row_index if row_index.include?(cellIndex)
    end

    return nil
  end

  # Returns the entire col of indicies that contain the given cellIndex.
  def col_indicies_for_cell_index(cellIndex)
    raise ArgumentError.new("Cell Index (#{cellIndex}) out of range!") if cellIndex < 0 or cellIndex >= (BOARD_SIZE * BOARD_SIZE)

    @col_indicies.each do |col_index|
      return col_index if col_index.include?(cellIndex)
    end

    return nil
  end
  
  # Returns the entire box of indicies that contain the given cellIndex.
  def box_indicies_for_cell_index(cellIndex)
    raise ArgumentError.new("Cell Index (#{cellIndex}) out of range!") if cellIndex < 0 or cellIndex >= (BOARD_SIZE * BOARD_SIZE)
  
    @box_indicies.each do |box_index|
      return box_index if box_index.include?(cellIndex)
    end

    return nil  
  end

  # Checks a board for validity based on if it contains any duplicate numbers in all rows, cols, and boxes.
  def valid?
    rows.each do |row|
      return false unless row.uniq.length == row.length
    end

    cols.each do |col|
      return false unless col.uniq.length == col.length
    end

    boxes.each do |box|
      return false unless box.uniq.length == box.length
    end

    return true
  end

  def solved?
    return ((@cells.include?("*") == false) and valid?)
  end
end

