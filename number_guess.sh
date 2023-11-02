#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Get username
echo "Enter your username:"
read USERNAME

# Check if user is in db
USERID=$($PSQL "SELECT id FROM users WHERE name = '$USERNAME'")
if [[ -z $USERID ]]
then
  QUERY_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USERID=$($PSQL "SELECT id FROM users WHERE name = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Get userdata from db
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USERID")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USERID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random num
RANDOM_NUM=$((1 + $RANDOM % 1000))
COUNT=0
GUESS=-1
echo "Guess the secret number between 1 and 1000:"

# Ask user for the guess
while true
do
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  if [ $GUESS -gt $RANDOM_NUM ]
  then
    echo "It's lower than that, guess again:"
  elif [ $GUESS -lt $RANDOM_NUM ]
  then
    echo "It's higher than that, guess again:"
  else
    ((COUNT++))
    QUERY_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($COUNT, $USERID)")
    echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
    exit 0
  fi
  ((COUNT++))
done

