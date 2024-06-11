#!/usr/bin/python3
"""
Query reddit users and total  subscribers
"""


def number_of_subscribers(subreddit):
    """
    Query reddit users and total  subscribers
    """
    import requests

    url = "https://www.reddit.com/r/{}/about.json".format(subreddit)
    headers = {
        'User-Agent': 'Mozilla/5.0'
    }
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        return response.json().get('data').get('subscribers')
    else:
        return 0
