#!/usr/bin/python3
"""
Query the Reddit API and return the number of
subscribers for a given subreddit
"""
import requests


def number_of_subscribers(subreddit):
    """
    Query the Reddit API and return the number of
    subscribers for a given subreddit
    """
    url = "https://www.reddit.com/r/{}/about.json".format(subreddit)
    headers = {'User-Agent': 'MyApp/1.0'}
    response = requests.get(url, headers=headers, allow_redirects=False)
    try:
        return response.json().get("data").get("subscribers")
    except Exception:
        return 0
