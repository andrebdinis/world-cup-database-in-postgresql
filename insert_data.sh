#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Truncate/erase all data from the tables before re-inserting them
echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # add each unique team to the "teams" table (24 rows)

  # if not the first line of .csv file (column titles)
  if [[ $YEAR != "year" ]]
  then
    # get team_id from winner team
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # Does winner team NOT exist in "teams" table?
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # if inserted successfully
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Winner inserted into teams, $WINNER
      fi
    fi

    # get team_id from opponent team
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # Does opponent team NOT exist in "teams" table?
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # if inserted successfully
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Opponent inserted into teams, $OPPONENT
      fi
    fi


    # insert a row for each line in the "games.csv" file (32 rows)

    # get winner_id and opponent_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if both teams id's exist
    if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]
    then
      # insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

      # if inserted successfully
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Game inserted, [$YEAR - $ROUND] $WINNER $WINNER_GOALS-$OPPONENT_GOALS $OPPONENT
      fi
    fi
  fi
done

# number of inserted rows for teams and games
TEAMS_ROWS=$($PSQL "SELECT COUNT(*) FROM teams")
echo -e "Teams inserted: $TEAMS_ROWS rows."
GAMES_ROWS=$($PSQL "SELECT COUNT(*) FROM games")
echo -e "Games inserted: $GAMES_ROWS rows."