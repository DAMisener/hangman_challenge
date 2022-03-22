# See: https://github.com/jasonswett/hangman_challenge

import strutils

type Word = string

# Error trapped input line from STDIN
template fromInput(): untyped =
  try: stdin.readLine except: ""

# Lower case input line from STDIN
template lcInput(): string = fromInput.toLowerAscii

# Syntactic suger for indefinite loop construct
template loop(statements: untyped) = 
  while true: statements

# Play a single session of Hangman game using specified word
proc game(hiddenWord: Word) =
  const MAX_GUESSES = 6

  type
    Guess = char
    State = enum PLAYING LOSE WIN

  var 
    filledWord = "-".repeat hiddenWord.len
    guess: Guess
    guessesLeft = MAX_GUESSES
    incorrectGuesses: Word 
    state = Playing

  # Obtain next of limited character guess
  template getGuess(): char = 
    guessesLeft.dec
    lcInput[0]

  # Display current status
  template showStatus() =
    var output = filledWord &  " life left: " & $guessesLeft
    if incorrectGuesses.len > 0: 
      output &= " incorrect guesses: " & incorrectGuesses
    echo output
  
  # Show final status of game
  template finalSummary() = 
    if guessesLeft == 0: state = LOSE
    echo "You ", state, '!'

  # wining status
  template won(): bool = state == WIN
    
  # Apply user specifie guess
  proc apply(guess: char) = 
    var
      changes = 0
      position = -1

    # Check if won
    template checkWin() = 
      if filledWord.count('-') == 0: state = WIN 

    # Maintain history of wrong guesses
    template recordIncorrectGuess() =
      if guess notin incorrectGuesses: incorrectGuesses.add guess 

    # Record good/bad guesses and check if all done
    loop:
      position = hiddenWord.find(guess, position + 1)
      if position < 0: break
      changes.inc
      filledWord[position] = guess
      
    if changes == 0: recordIncorrectGuess
    checkWin
      
  while guessesLeft > 0:
    showStatus
    apply getGuess
    if won: break

  finalSummary

# Get next hidden word
template getWord(): Word = lcInput

# Play one or more games (terminated by EOF or blank line)
proc play() =
  loop:
    let word = getWord()
    if word == "": break
    game word

if isMainModule: play()