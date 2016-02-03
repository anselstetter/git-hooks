#!/bin/sh

GITROOT=$(git -C $1 rev-parse --show-toplevel 2> /dev/null)
FILES=("functions" "pre-push" "pre-commit")

function clean() {
	for file in "${FILES[@]}"; do
		echo "Deleting $file"
		rm $GITROOT/.git/hooks/$file
	done
}

function install() {
	for file in "${FILES[@]}"; do
		check_existing_hook $file
		install_hook $file
		verify_hook $file
		make_executable $file
	done

	echo "Done"
}

function assert_git_directory() {
	if [ "$GITROOT" == "" ]; then
		echo "This does not appear to be a git repo."
		exit 1
	else
		echo "This appears to be a git repo."
	fi
}

function check_existing_hook() {
	if [ -f "$GITROOT/.git/hooks/$1" ]; then
		echo "There is already a $1 hook installed. Delete it first, or use -f switch to force installation"
		echo
		echo "rm '$GITROOT/.git/hooks/$1'"
		echo 
		exit 1
	fi
}

function install_hook() {
	echo "Installing hook $1"
	cp ./$1 $GITROOT/.git/hooks/$1
}

function verify_hook() {
	echo "Verifying hook $1"
	if [ ! -f "$GITROOT/.git/hooks/$1" ]; then
		echo "Error installing $1 hook!"
		exit 1
	fi
}

function make_executable() {
	chmod +x "$GITROOT/.git/hooks/$1"
}

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <git directory> [-f]" >&2
	exit 1
fi

if [ "$2" == "-f" ]; then
	clean
fi

assert_git_directory
install
