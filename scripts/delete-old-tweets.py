#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

from datetime import datetime, timedelta
import os

import tweepy


def get_api_client():
    auth = tweepy.OAuthHandler(
        consumer_key=os.environ["CONSUMER_KEY"],
        consumer_secret=os.environ["CONSUMER_SECRET"],
    )
    auth.set_access_token(
        key=os.environ["ACCESS_TOKEN"], secret=os.environ["ACCESS_TOKEN_SECRET"],
    )
    return tweepy.API(auth)


def delete_old_tweets(api):
    one_year_ago = datetime.now() - timedelta(days=365)
    for status in tweepy.Cursor(api.user_timeline).items():
        if status.created_at < one_year_ago:
            print("deleting:", status.created_at.isoformat(), status.text)
            api.destroy_status(status.id)


def main():
    api = get_api_client()
    delete_old_tweets(api)


if __name__ == "__main__":
    main()
