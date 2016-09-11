# Create Local Repository
Set up a local git repository with development and production environments

Each project consists of a local git repository, as well as a separate development and production directory.

Changes pushed from either environment to the git repository will be synced over to the other.

Directory structure: 

    projects/                  # root directory for your projects and location of clr.sh
       clr.sh                  # the create-local-repository executable
       project_1/              # project's production directory
       dev/                    # development directory
           project_1/          # project's development directory
       git/                    # git repository directory
           project_1/          # project's git repository directory

## Usage
### Create a new project
`./clr.sh PROJECT_NAME`

If PROJECT_NAME is not specified, you will be prompted to enter a project name.
The project name is used as the name of all project directories.

    Enter a project name to be used for project directories:
    (n to exit)

### Delete an existing project
`./clr.sh PROJECT_NAME delete`

### Pushing Changes
`git push hub master`

## Examples
Create a new project:

    ./clr.sh space_station

    Created new directory: /c/projects/dev
    Created new directory: /c/projects/git

    Setting up git repository:
    Created new directory: /c/projects/git/space_station
    Initialized empty Git repository in C:/projects/git/space_station/

    Setting up production environment:
    Created new directory: /c/projects/space_station
    Initialized empty Git repository in C:/projects/space_station/.git/

    Setting up development environment:
    Created new directory: /c/projects/dev/space_station
    Cloning into 'C:/projects/dev/space_station'...
    warning: You appear to have cloned an empty repository.
    done.

Delete an existing project:

    ./clr.sh space_station delete

    You are about to remove the following directories and all containing folders.
    Are you sure you want to proceed?
    (y or n)
    y
    Deleted: /c/projects/space_station
    Deleted: /c/projects/dev/space_station
    Deleted: /c/projects/git/space_station

## Notes
This project was created to test out working with a local git repository hub and setting up git hooks for syncing development and production environments.