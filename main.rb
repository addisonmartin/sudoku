require_relative 'board'
require_relative 'puzzle'

puzzle = Puzzle.new({name: 'Test', source: 'My Head', difficulty: 'Trivial', board: Board.new("/home/addisonmartin/Documents/sudoku/puzzles/test3.sudoku")})

puzzle.solve

