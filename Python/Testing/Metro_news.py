# testing code from: https://www.youtube.com/watch?v=EmDwXmwxVW8

from requests_html import HTMLSession

s = HTMLSession()
r = s.get('https://metro.co.uk/news/tech/')
# Info in channel middle - mosaic div
posts = r.html.find('ul.metro-mosaic', first=True).find('h2')

data = [(post.text, post.find('a', first=True).attrs['href']) for post in posts]

#for post in posts:
#    print(post.text, post.find('a', first=True).attrs['href'])

print(data)
