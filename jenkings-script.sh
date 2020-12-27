#!/bin/sh
ENV=$1
FLAGS=$2
COMMAND="bundle exec cucumber"
eval "source $ENV"
cd cucumber
bundle install
eval "$COMMAND $FLAGS"