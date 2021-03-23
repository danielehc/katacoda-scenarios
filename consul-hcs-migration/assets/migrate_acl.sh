#! /bin/bash

# ++-----------------+
# || Functions       |
# ++-----------------+

## Prints a line on stdout prepended with date and time
log() {
  echo -e "\033[1m["$(date +"%Y-%d-%d %H:%M:%S")"] - ${@}\033[0m"
}

## Prints a header on stdout
header() {

  echo -e " \033[1m\033[32m"

  echo ""
  echo "++----------- " 
  echo "||   ${@} "
  echo "++------      " 

  echo -e "\033[0m"
}

## STEPS

## EXPORT
# 1. Retrieve all the policy definitions. Do a listing and then for each ID perform a read.

# 2. Recreate the policies in the new DC and keep a mapping of old ids to new ids.

# 3. Retrieve all the role definitions. Again listing + read for all of them.

## IMPORT
# 4. Recreate the roles in the new DC and keep a map of old role ids to new ids. During this step replace any linked policy ids with the new ids.

# 5. Retrieve all the token definitions. List + read.

# 6. Recreate the tokens including specifying the token secret. Map the old policy/role ids to the newly created ids.


## Check Parameters
if   [ "$1" == "export" ]; then

  echo "export"
  exit 0

elif [ "$1" == "import" ]; then

  echo "import"
  exit 0

fi