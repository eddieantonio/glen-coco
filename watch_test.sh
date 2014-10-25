#!/bin/sh

# Runs the Jasmine spec watcher the way I like it.
# Installs the exact version of jasmine-node if it doesn't exist.

JASMINE_NODE=./node_modules/.bin/jasmine-node
stat $JASMINE_NODE > /dev/null || npm install 'jasmine-node@^1.14.3'
$JASMINE_NODE spec --coffee --color --autotest --watch lib
