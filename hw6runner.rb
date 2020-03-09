# Programming Languages, Homework 6, hw6runner.rb

require_relative './hw6provided'
require_relative './hw6assignment'
require_relative './challenge.rb'

def runTetris
  Tetris.new 
  mainLoop
end

def runMyTetris
  MyTetris.new
  mainLoop
end

def runMyTetrisChallenge
  MyTetrisChallenge.new
  mainLoop
end

if ARGV.count == 0
  runMyTetris
elsif ARGV.count != 1
  puts "usage: hw6runner.rb [enhanced | original | challenge]"
elsif ARGV[0] == "enhanced"
  runMyTetris
elsif ARGV[0] == "original"
  runTetris
elsif ARGV[0] == "challenge"
  runMyTetrisChallenge
else
  puts "usage: hw6runner.rb [enhanced | original | challenge]"
end

