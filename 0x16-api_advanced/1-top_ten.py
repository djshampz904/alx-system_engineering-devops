#!/usr/bin/python3
"""
Query the Reddit API and prints the
titles of the first 10 hot
posts listed for a given subreddit.
"""
import requests


def top_ten(subreddit):
    """
    Query the Reddit API and prints the
    titles of the first 10 hot
    posts listed for a given subreddit.
    """
    url = "https://www.reddit.com/r/{}/hot.json?limit=10".format(subreddit)
    headers = {'User-Agent': 'MyApp/1.0'}
    response = requests.get(url, headers=headers, allow_redirects=False)
    if response.status_code != 200:
        print(None)
        return
    try:
        posts = response.json().get("data").get("children")
        for post in posts:
            print(post.get("data").get("title"))
    except Exception:
        print(None)
