#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
GUESS_COUNT=0

# guess loop 
GUESS () {
  read NUMBER 

  # if input is not an integer
  if [[ ! $NUMBER =~ ^[0-9]+ ]] 
  then 
    # error message
    echo -e "That is not an integer, guess again:"
    GUESS

  # if input is greater than number
  elif [[ $NUMBER -gt $NUMBER_TO_GUESS ]]
  then 
    # increase guess count & display message
    let "GUESS_COUNT++"
    echo -e "It's lower than that, guess again:"
    GUESS

  # if input is lower than number
  elif [[ $NUMBER -lt $NUMBER_TO_GUESS ]]
  then
    # increase guess count & display message 
    let "GUESS_COUNT++"
    echo -e "It's higher than that, guess again:"
    GUESS

  # if input is the correct number
  elif [[ $NUMBER -eq $NUMBER_TO_GUESS ]]
  then
    # increase guess count & display message
      let "GUESS_COUNT++"
      echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
  fi    
}


echo -e "\n~~~~~ Welcome to the number guessing game ~~~~~\n"


# ask for username
echo -e "\nEnter your username:"
read USER

USERNAME_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USER'")

# if username does not exist
if [[ -z $USERNAME_RESULT ]]
then  
  # insert new username into database
  NEW_USERNAME_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES ('$USER', 0, 0)")
 
  # get username info
  USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USER'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER'")

  # welcome message 
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."

else
  # get username info
  USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USER'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER'")

  # welcome back message
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generate number between 1 and 1000
NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1))

# number guess message
echo -e "Guess the secret number between 1 and 1000:"  
GUESS

# update the number of games played
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = users.games_played + 1 WHERE username='$USER'")

# update best game
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER'")

# check if best game should be updated
if [[ $BEST_GAME -eq 0 || $BEST_GAME -gt $GUESS_COUNT ]]
then
  # update best game
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE username='$USER'")
fi
