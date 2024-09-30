#!/bin/bash

PSQL="psql -U freecodecamp -t --no-align number_guess -c"

READ_NUMBER() {
  
  if [[ ! -z $1 ]]
  then
    echo $1
  fi

  read NUMBER
}

until [[ ! -z $USERNAME ]]
do
  echo "Enter your username:"
  read USERNAME
done

GET_USER_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $GET_USER_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")

  GET_USER_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  IFS="|" read USER_ID USERNAME <<< $GET_USER_RESULT

else
  IFS="|" read USER_ID USERNAME <<< $GET_USER_RESULT
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(tries) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RAND_NUMBER=$(( $RANDOM % 1000 ))
TRIES=1

echo "Guess the secret number between 1 and 1000:"

READ_NUMBER

until [[ $NUMBER -eq $RAND_NUMBER ]]
do

  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    READ_NUMBER "That is not an integer, guess again:"
  else

    if [[ $RAND_NUMBER -lt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    
    READ_NUMBER
    (( TRIES++ ))

  fi

done

echo "You guessed it in $TRIES tries. The secret number was $RAND_NUMBER. Nice job!"

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, tries) VALUES ($USER_ID, $TRIES)")
