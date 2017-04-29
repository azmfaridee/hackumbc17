import requests
from bs4 import BeautifulSoup
import pandas as pd
import unicodedata

# use this if you want to directly parse from the website
# pageContent = requests.get('http://informationsystems.umbc.edu/home/faculty-and-staff/faculty/')
# soup = BeautifulSoup(pageContent.content)

# offline parsing code
with open('raw-data/faculty.html', encoding='utf-8') as f: facultyHtml = f.read()
soup = BeautifulSoup(facultyHtml)
# print(soup.prettify())
article = soup.select('body#home div#container section.page-container.layout-default section.page-content section.main-content article')[0]

names = []
for item in [item.string for item in article.select('h6 a')]:
    if not '@umbc.edu' in item: names.append(item)

qualifiedNames, researchDescriptions = [], []
for item in article.select('h6'):
    if item.text:
        qualifiedNames.append(unicodedata.normalize("NFKD", item.text))    
        researchDescriptions.append(unicodedata.normalize("NFKD", item.next_sibling.next_sibling.text))
data = dict(zip(qualifiedNames, researchDescriptions))
df = pd.DataFrame([qualifiedNames, researchDescriptions]).T
df.columns = ['qualifiedNames', 'researchDescriptions']
df.to_csv('crawled-data/faculty.csv')