#!/bin/bash
# poor man's build script for the blog
# see also https://github.com/envygeeks/jekyll-docker/blob/master/README.md

JEKYLL_VERSION=3.8
MAP_DIR="/srv/jekyll"
REPO_URL="https://github.com/raphaelthomas/ofcampuszh.ch.git"
REPO_DIR="$HOME/tmp/ofcampuszh.ch"
COMMIT_LOG="$REPO_DIR/_includes/commit"

GIT="git --git-dir=$REPO_DIR/.git --work-tree=$REPO_DIR"

if [ ! -d "$REPO_DIR" ]; then
    mkdir -p $REPO_DIR
    git clone $REPO_URL $REPO_DIR
fi

$GIT remote update


# build & rsync develop branch
$GIT checkout develop
$GIT pull origin develop
$GIT rev-parse HEAD > $COMMIT_LOG

docker run --rm --volume="$REPO_DIR:$MAP_DIR" -it jekyll/builder:$JEKYLL_VERSION jekyll build --config "$MAP_DIR/_config.yml,$MAP_DIR/_config-dev.yml" --drafts --unpublished
rsync -rv $REPO_DIR/_site/* $HOST:/var/www/ch.ofcampuszh.dev


# build & rsync master branch
$GIT checkout master
$GIT pull origin master
$GIT rev-parse HEAD > $COMMIT_LOG

docker run --rm --volume="$REPO_DIR:$MAP_DIR" -it jekyll/builder:$JEKYLL_VERSION jekyll build --config "$MAP_DIR/_config.yml,$MAP_DIR/_config-prod.yml"
rsync -rv $REPO_DIR/_site/* $HOST:/var/www/ch.ofcampuszh


# clean up
rm $COMMIT_LOG
