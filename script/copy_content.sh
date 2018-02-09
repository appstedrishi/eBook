#!/bin/bash
RSYNC_CMD="rsync -a --exclude=.svn"

if [ $CONFIGURATION == "Distribute" ]; then
	echo "Deleting /Content/textbook ..."
	rm -rf $SRCROOT/Content/textbook ;
	echo "Done."
else
    echo "Using existing /Content/textbook, but delete JS and CSS so they'll be regenerated"
    rm -rf $SRCROOT/Content/textbook/javascript;
    rm -rf $SRCROOT/Content/textbook/css;
fi

mkdir -p $SRCROOT/Content/textbook/css
mkdir -p $SRCROOT/Content/textbook/javascript


$RSYNC_CMD $SRCROOT/Content/Life11eCh6/images $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/thumb $SRCROOT/Content/textbook/

$RSYNC_CMD $SRCROOT/Content/Life11eCh6/book/chapter* $SRCROOT/Content/textbook/book/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/book/rm $SRCROOT/Content/textbook/book
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/book/figures $SRCROOT/Content/textbook/book/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/glossary $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/index.xml $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/video $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/images_misc $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/index.html $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Life11eCh6/css $SRCROOT/Content/textbook/

$RSYNC_CMD $SRCROOT/Content/Common/html $SRCROOT/Content/textbook/
$RSYNC_CMD $SRCROOT/Content/Common/images $SRCROOT/Content/textbook/

# yes, copy ALL javascript files over, as some are used individually as opposed to being used in halo-common.js
$RSYNC_CMD $SRCROOT/Content/Common/javascript $SRCROOT/Content/textbook/

cat $SRCROOT/Content/Common/css/halo.css \
  > $SRCROOT/Content/textbook/css/halo-common.css

cat $SRCROOT/Content/Common/javascript/jquery-1.4.2.min.js \
    $SRCROOT/Content/Common/javascript/jquery.json-2.2.js \
    $SRCROOT/Content/Common/javascript/bt-0.9.5-rc1/jquery.bt.js \
    $SRCROOT/Content/Common/javascript/click.js \
    $SRCROOT/Content/Common/javascript/halo.js \
    $SRCROOT/Content/Common/javascript/ns-bridge.js \
    $SRCROOT/Content/Common/javascript/keyword.js \
    $SRCROOT/Content/Common/javascript/glossary.js \
    $SRCROOT/Content/Common/javascript/highlight.js \
    $SRCROOT/Content/Common/javascript/highlighter.js \
    $SRCROOT/Content/Common/javascript/node-indexer.js \
    $SRCROOT/Content/Common/javascript/node-serializer.js \
    $SRCROOT/Content/Common/javascript/touch-event-handler.js \
    $SRCROOT/Content/Common/javascript/summarizer.js \
    $SRCROOT/Content/Common/javascript/logger.js \
  > $SRCROOT/Content/textbook/javascript/halo-common.js
