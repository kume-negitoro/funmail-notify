#/bin/bash

## user config ##
CACHE_DIR=$HOME/.funmail-notify
MAX_RETRY_COUNT=1
NOTIFY_MESSAGE=">
新着メールがあります
https://webmail.fun.ac.jp
"`date +"%Y/%m/%d %H:%M:%S"`

### Usage ###
#
# $ FUNMAIL_ID=<ID> FUNMAIL_PW=<PASSWORD> FUNMAIL_LINE_TOKEN=<TOKEN> /path/to/funmail.sh
#
# or
# $ export FUNMAIL_ID=<ID>
# $ export FUNMAIL_PW=<PASSWORD>
# $ export FUNMAIL_LINE_TOKEN=<TOKEN>
# $ /path/to/funmail.sh
#
# or cron example:
# FUNMAIL_ID=<ID>
# FUNMAIL_PW=<PASSWORD>
# FUNMAIL_LINE_TOKEN=<TOKEN>
# */5 * * * * /path/to/dir/funmail-notify.sh
#
# Requirements:
# - curl
# - jq
#
###

# ID is required
if [ -z "$FUNMAIL_ID" ]; then
    echo "error: \$FUNMAIL_ID couldn't be empty."
    exit 1
fi

# Password is required
if [ -z "$FUNMAIL_PW" ]; then
    echo "error: \$FUNMAIL_PW couldn't be empty."
    exit 1
fi

# endpoint
LOGIN_CGI=https://webmail.fun.ac.jp/cgi-bin/login.cgi
NEWMAIL_CGI=https://webmail.fun.ac.jp/cgi-bin/newmail.cgi

# config directory and file names
COOKIE_NAME=cookie
TOTAL_CACHE_NAME=total
COOKIE_PATH=$CACHE_DIR/$COOKIE_NAME
TOTAL_CACHE_PATH=$CACHE_DIR/$TOTAL_CACHE_NAME

# setup files and directories
mkdir -p $CACHE_DIR
if [ ! -f $TOTAL_CACHE_PATH ]; then
    echo 0 > $TOTAL_CACHE_PATH
fi

main () {

    if [ $1 -gt $MAX_RETRY_COUNT ]; then
        echo "-- error: Retry count exceeded \$MAX_RETRY_COUNT."
        exit 1
    fi

    # fetch new mail information
    response=`curl -s -b "$COOKIE_PATH" -v "$NEWMAIL_CGI"`

    echo $response

    # get total mail count
    total=`echo $response | jq '.folderstat | map(select(.folderkey=="inbox")) | .[0].total | tonumber'`
    # get unread mail count
    unread=`echo $response | jq '.folderstat | map(select(.folderkey=="inbox")) | .[0].unread | tonumber'`

    # check result value
    if [ -n "$total" ]; then
        prev_total=`cat $TOTAL_CACHE_PATH`

        echo $total > $TOTAL_CACHE_PATH

        if [ $total -gt $prev_total ] && [ $unread -gt 0 ]; then
            # send notification
            curl -X POST \
                -H "Authorization: Bearer $FUNMAIL_LINE_TOKEN" \
                -F "message=\"$NOTIFY_MESSAGE\"" \
                https://notify-api.line.me/api/notify
        fi

        echo "-- result: There are "$total", "$unread" unread messages"
    else
        echo "-- warning: Session is timed out. Trying login."

        # try login
        curl -s -X POST -d id="$FUNMAIL_ID" -d pwd="$FUNMAIL_PW" -c "$COOKIE_PATH" -v "$LOGIN_CGI"
        main $(($1 + 1))
    fi
}

main 0
