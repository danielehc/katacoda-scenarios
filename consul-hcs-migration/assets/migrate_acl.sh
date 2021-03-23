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

ex_port () {
  
  EXP_PATH="./export"
  
  rm -rf $EXP_PATH
  
  mkdir -p ${EXP_PATH}
  
  touch ${EXP_PATH}/policies.csv

  for id in `consul acl policy list -format json | jq -r '.[].ID' | grep -v 00000000-0000-0000-0000-000000000001`; do

    json_policy=`consul acl policy read -id $id -format json`

    echo $json_policy | jq -r '[.ID, .Name, .Description] | @csv' >> ${EXP_PATH}/policies.csv
    echo $json_policy | jq -r '.Rules' > ${EXP_PATH}/policy_$id.hcl

  done

}

## STEPS

## EXPORT
# 1. Retrieve all the policy definitions. Do a listing and then for each ID perform a read.
###
###
###

# $ consul acl policy list -format json | jq -r '.[].ID'
# 00000000-0000-0000-0000-000000000001
# 206b483c-0676-ea69-28b7-1776fd251b9e
# d12debb6-484f-5dfe-3fa9-13949c2cddc8

# $ consul acl policy list -format json | jq -r '.[].ID' | grep -v 00000000-0000-0000-0000-000000000001
# 206b483c-0676-ea69-28b7-1776fd251b9e
# d12debb6-484f-5dfe-3fa9-13949c2cddc8

# jq '.data | map([.displayName, .rank, .value] | join(", ")) | join("\n")'
# jq -r '.data | map(.ID), map(.Name), map(.Description) | join(", ")'

# map[.ID, .Name, .Description]

# consul acl policy read -id 206b483c-0676-ea69-28b7-1776fd251b9e | grep -oz "Rules.*" | grep -va Rules

# consul acl policy read -id 206b483c-0676-ea69-28b7-1776fd251b9e -format json | jq -r '.Rules'
# consul acl policy read -id 206b483c-0676-ea69-28b7-1776fd251b9e -format json | jq -r '.ID'
# consul acl policy read -id 206b483c-0676-ea69-28b7-1776fd251b9e -format json | jq -r '.Name'
# consul acl policy read -id 206b483c-0676-ea69-28b7-1776fd251b9e -format json | jq -r '.Description'

# consul acl policy read -id 1c822a11-5088-fc55-4335-6ff2662838f5 -format json | jq -r '[.ID, .Name, .Description] | @csv'

# 2. Recreate the policies in the new DC and keep a mapping of old ids to new ids.

# 3. Retrieve all the role definitions. Again listing + read for all of them.

## IMPORT
# 4. Recreate the roles in the new DC and keep a map of old role ids to new ids. During this step replace any linked policy ids with the new ids.

# 5. Retrieve all the token definitions. List + read.

# 6. Recreate the tokens including specifying the token secret. Map the old policy/role ids to the newly created ids.


## Check Parameters
if   [ "$1" == "export" ]; then

  echo "export"
  ex_port
  exit 0

elif [ "$1" == "import" ]; then

  echo "import"
  exit 0

fi