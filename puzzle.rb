require_relative 'board'

class Puzzle

  attr_accessor :name, :difficulty, :source, :board

  def initialize(args={})
    @name = args[:name] if args[:name]
    @difficulty = args[:difficulty] if args[:difficulty]
    @source = args[:source] if args[:source]
    if args[:board]
      @board = args[:board]
      raise ArgumentError.new("Board must be a sudoku/board.rb object!") unless @board.is_a? Board
      raise ArgumentError.new("Board is invalid!") unless @board.valid?
    end
  end

  def to_s
    result = "Sudoku Puzzle: #{@name}"
    result += "\nDifficulty: #{@difficulty}"
    result += "\nSource: #{@source}"
    result += "\n"
    result += board.to_s

    result
  end

  def solve
    
    puts @board

    while not @board.solved? do

      raise RuntimeError.new("Board is in an invalid state!") unless @board.valid?

      solve_boxes
      solve_rows
      solve_cols
    end

    puts "Solved!"
  end

  def solve_boxes
    boxes = @board.boxes
    box_indicies = @board.box_indicies

    # Go through each box within the board
    boxes.each_with_index do |box, box_index|
      # Get all remaining values that still need to be filled in the box
      remaining_values = Array(1..Board::BOARD_SIZE) - box

      box_guesses = {}

      # Go through each cell within the box
      box_indicies[box_index].each do |cell_index|
        # Skip cells that already have values
	next unless @board.cells[cell_index] == "*"

	box_guesses[cell_index] = []

	# Go through each remaining value that still needs to be filled in the box
	remaining_values.each do |remaining_value|
	  row_indicies = @board.row_indicies_for_cell_index(cell_index)
	  col_indicies = @board.col_indicies_for_cell_index(cell_index)

	  row_values = []
	  row_indicies.each do |row_index|
	    row_values << @board.cells[row_index]
	  end

	  col_values = []
	  col_indicies.each do |col_index|
	    col_values << @board.cells[col_index]
	  end

	  # Add the remaning value to the possible guesses at the index, if neither the cell's row nor col contain the remaining value
	  box_guesses[cell_index] << remaining_value if (not row_values.include?(remaining_value) and not col_values.include?(remaining_value))
	end
      end
			
      check_for_single_guess_occurrences(box_guesses)
    end
  end

  def solve_rows
    rows = @board.rows
    row_indicies = @board.row_indicies

    # Go through each row within the board
    rows.each_with_index do |row, row_index|
      # Get all remaining values that still need to be filled in the row
      remaining_values = Array(1..Board::BOARD_SIZE) - row

      row_guesses = {}

      # Go through each cell within the row
      row_indicies[row_index].each do |cell_index|
        # Skip cells that already have values
        next unless @board.cells[cell_index] == "*"

        row_guesses[cell_index] = []

        # Go through each remaining value that still needs to be filled in the row
        remaining_values.each do |remaining_value|
          col_indicies = @board.col_indicies_for_cell_index(cell_index)

          col_values = []
          col_indicies.each do |col_index|
            col_values << @board.cells[col_index]
          end

          # Add the remaning value to the possible guesses at the index, if the cell's col does not contain the remaining value
          row_guesses[cell_index] << remaining_value unless col_values.include?(remaining_value)
        end
      end

      check_for_single_guess_occurrences(row_guesses)
    end
  end

  def solve_cols
    cols = @board.cols
    col_indicies = @board.col_indicies
    
    # Go through each col within the board
    cols.each_with_index do |col, col_index|
      # Get all remaining values that still need to be filled in the col
      remaining_values = Array(1..Board::BOARD_SIZE) - col

      col_guesses = {}
     
      # Go through each cell within the col
      col_indicies[col_index].each do |cell_index|
        # Skip cells that already have values
        next unless @board.cells[cell_index] == "*"

        col_guesses[cell_index] = []

        # Go through each remaining value that still needs to be filled in the col
        remaining_values.each do |remaining_value|
          row_indicies = @board.row_indicies_for_cell_index(cell_index)

          row_values = []
          row_indicies.each do |row_index|
            row_values << @board.cells[row_index]
          end

          # Add the remaning value to the possible guesses at the index, if the cell's row does not contain the remaining value.
          col_guesses[cell_index] << remaining_value unless row_values.include?(remaining_value)
        end
      end
      
      check_for_single_guess_occurrences(col_guesses)
    end
  end

  def check_for_single_guess_occurrences(region_guesses)
    # Count how many times each guess appears in the region.
    guess_occurrences = {}
    region_guesses.each do |index, guesses|
      guesses.each do |guess|
        if guess_occurrences[guess].nil?
          guess_occurrences[guess] = [1, index] # Also store the cell index for later use when filling in guesses.
        else
          guess_occurrences[guess][0] += 1
        end
      end
    end

    guess_occurrences.each do |guess, occurrences_and_index|
      occurrences = occurrences_and_index[0]
      index = occurrences_and_index[1]
      # If there is only one possible cell for a remaining value, then fill in that value and stop checking remaining guesses.
      if occurrences == 1
        @board.cells[index] = guess
        puts @board
        return
      end
    end
  end
end

