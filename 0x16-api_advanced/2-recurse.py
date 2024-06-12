#!/usr/bin/python3
"""
recursive function that queries the Reddit API
and returns a list containing the titles of all
hot articles for a given subreddit. If no
results are found for the given subreddit,
the function should return None.
"""
import requests


def recurse(subreddit, hot_list=[], after=None):
    """
    recursive function that queries the Reddit API
    and returns a list containing the titles of all
    hot articles for a given subreddit. If no
    results are found for the given subreddit,
    the function should return None.
    """
    url = "https://www.reddit.com/r/{}/hot.json".format(subreddit)
    if after:
        url += "?after={}".format(after)
    headers = {'User-Agent': 'MyApp/1.0'}
    response = requests.get(url, headers=headers, allow_redirects=False)
    if response.status_code != 200:
        return None
    try:
        data = response.json().get("data")
        after = data.get("after")
        posts = data.get("children")
        for post in posts:
            hot_list.append(post.get("data").get("title"))
        if after:
            return recurse(subreddit, hot_list, after)
    except Exception:
        return None
    return hot_list
