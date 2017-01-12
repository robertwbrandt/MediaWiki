# -*- coding: utf-8 -*-
import requests

username = 'USERNAME'
password = 'PASSWORD'
baseurl = 'https://test.wikipedia.org/w/'
summary = 'bot hello'
message = 'Hello Wikipedia. I am alive!'
title = 'Sandbox'

# Login request
payload = {'action': 'query', 'format': 'json', 'utf8': '', 'meta': 'tokens', 'type': 'login'}
r1 = requests.post(baseurl + 'api.php', data=payload)

# login confirm
login_token = r1.json()['query']['tokens']['logintoken']
payload = {'action': 'login', 'format': 'json', 'utf8': '', 'lgname': username, 'lgpassword': password, 'lgtoken': login_token}
r2 = requests.post(baseurl + 'api.php', data=payload, cookies=r1.cookies)

# get edit token2
params3 = '?format=json&action=query&meta=tokens&continue='
r3 = requests.get(baseurl + 'api.php' + params3, cookies=r2.cookies)
edit_token = r3.json()['query']['tokens']['csrftoken']

edit_cookie = r2.cookies.copy()
edit_cookie.update(r3.cookies)

# save action
payload = {'action': 'edit', 'assert': 'user', 'format': 'json', 'utf8': '', 'appendtext': message,'summary': summary, 'title': title, 'token': edit_token}
r4 = requests.post(baseurl + 'api.php', data=payload, cookies=edit_cookie)

print (r4.text)