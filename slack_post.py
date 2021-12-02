#!/usr/bin/env python3

import configparser

import requests
import argparse

import json

def get_parser():
    parser = argparse.ArgumentParser(description="Send Slack message",
            formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("key_ini", help="key.ini file that has token and chat_id fields in [Telegram]")
    parser.add_argument("--title", help="Title")
    parser.add_argument("--body", help="Body", required=True)
    return parser

def escape_html_str(string: str) -> str:
    string = string.replace('&', '&amp;')
    string = string.replace('<', '&lt;')
    string = string.replace('>', '&gt;')
    return string


# slack_token is URL like https://hooks.slack.com/services/...
def send_text(slack_token, text):
    text = escape_html_str(text)
    return requests.post(slack_token, data=json.dumps({'text': text}),
        headers={'Content-Type': 'application/json'})

def send_text_with_title(slack_token, title, body):
    if title:
        blocks = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": title,
                        "emoji": True
                    }
                },
                {
                    "type": "section",
                    "text": {
                        "type": "plain_text",
                        "text": body,
                        "emoji": True
                    }
                }
            ]
        }

        return requests.post(slack_token, data=json.dumps(blocks),
            headers={'Content-Type': 'application/json'})
    else:
        slack_request = send_text(slack_token, body)

    return slack_request

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()

    key = configparser.ConfigParser()
    key.read(args.key_ini)

    tokens = key['Slack']['tokens'].split(',')

    if not tokens:
        raise KeyError('No Slack bot given')

    for token in tokens:
        print(send_text_with_title(token, args.title, args.body))
