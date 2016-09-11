#!/bin/sh

# script to create a new project
# sets up git repository in a git 'hub'' as well as development / production environments

# variables
PROJECT=$1 # project name
DELETE=$2 # used to delete project 
ACTION= # deletion confirmation
FOUND=() # array of existing directories with project name
ERRORS=() # array of existing directories with project name
BASE=$PWD # projects directory root 

# Check for project name
while [ -z "$PROJECT" ]; do
    
    # Request project name
    echo -e "\nEnter a project name to be used for project directories:"
    echo -e "(n to exit)"
    read PROJECT
    
    # exit on 'exit' or 'n'
    if [ "${PROJECT}" = 'exit' ] || [ "${PROJECT}" = 'n' ]; then exit; fi
    
done

# project paths
DEV_DIR=$BASE/dev
GIT_DIR=$BASE/git
PRODUCTION=$BASE/$PROJECT
DEVELOPMENT=$DEV_DIR/$PROJECT
HUB=$GIT_DIR/$PROJECT

# development/production/hub paths
PATHS=("$PRODUCTION" "$DEVELOPMENT" "$HUB")

# base paths
BASE_PATHS=("$DEV_DIR" "$GIT_DIR")

# Create initial directories
for i in "${BASE_PATHS[@]}"; do 
    if [ ! -d $i ]; then 
        if mkdir $i; 
            then echo -e "Created new directory: $i"; 
            else echo "Unable to create directory: $i"; exit;
        fi; 
    fi
done

delete_project() {
    if [ $1 ]; then ACTION=y; fi
    # Confirm delete request
    while [ ! "$ACTION" = 'y' ] && [ ! "$ACTION" = 'n' ] || [ -z "$ACTION" ]; do 
        echo -e "\nYou are about to remove the following directories and all containing folders."

        echo -e "Are you sure you want to proceed?\n(y or n)"
        read ACTION
    done
    
    # If 'Y' then proceed with deletion
    if [ "$ACTION" = 'y' ]; then
        for i in "${PATHS[@]}"; do 
            if [ -d $i ]; then 
             
                # Directory and contents deleted
                if rm -rf $i; then echo -e "Deleted: $i"; fi
                
                # Directory not found
                else echo -e "Not Found: $i"; 
                
            fi
        done
            
        # Exit once cycled through all paths
        exit
        
    # If 'N' then just exit
    else echo -e "\nExiting - no changes made"; exit; fi
}

# Delete project
if [ "$DELETE" = 'delete' ]; then delete_project; fi

# Check to see if directories already exist
for i in "${PATHS[@]}"; do 
   if [ -d $i ]; then FOUND+=($i); fi
done

# Do not proceed if any directories exist with the requested project name
if [ "${#FOUND[@]}" -ne 0 ]; then

    # List existing directories
    echo -e "\nExisting directories found:"
    for i in "${FOUND[@]}"; do echo -e "\t$i"; done
    
    # Request a new name and exit
    echo -e "\nPICK A DIFFERENT NAME AND TRY AGAIN"
    exit
fi

# HUB
echo -e "\nSetting up git repository:"
if mkdir $HUB; then echo -e "Created new directory: $HUB"; else ERROR+=('Issue creating $HUB'); continue; fi
cd $HUB
git init --bare
touch hooks/post-update
chmod +x hooks/post-update
echo "#!/bin/sh" >> hooks/post-update
echo "cd" $PRODUCTION >> hooks/post-update
echo "unset GIT_DIR" >> hooks/post-update
echo "git pull hub master" >> hooks/post-update
echo "cd ."$DEVELOPMENT >> hooks/post-update
echo "unset GIT_DIR" >> hooks/post-update
echo "git pull hub master" >> hooks/post-update
echo "exec git-update-server-info" >> hooks/post-update
cd $BASE

# PRODUCTION
echo -e "\nSetting up production environment:"
if mkdir $PRODUCTION; then echo -e "Created new directory: $PRODUCTION"; else continue; fi
cd $PRODUCTION
git init
git remote add hub $HUB
touch .git/hooks/post-commit
chmod +x .git/hooks/post-commit
echo "#!/bin/sh" >> .git/hooks/post-commit
echo "git push hub master" >> .git/hooks/post-commit
cd $BASE

# DEVELOPMENT
echo -e "\nSetting up development environment:"
if mkdir $DEVELOPMENT; then echo -e "Created new directory: $DEVELOPMENT"; else continue; fi
git clone $BASE/git/$PROJECT $DEVELOPMENT
cd $DEVELOPMENT
git remote rename origin hub
cd $BASE

# if there are any errors undo everything and remove project
if [ "${#ERRORS[@]}" -ne 0 ]; then delete_project test; echo "Deleted project"; exit; fi
