import requests
from bs4 import BeautifulSoup
import pandas as pd
import unicodedata

# http://www.sc.edu/study/colleges_schools/engineering_and_computing/study/areas_of_study/computer_science_and_engineering/our_people/index.php
# def parseFaculty():
with open('raw-data/faculty-ucsc.html', encoding='utf-8') as f: facultyHtml = f.read()
soup = BeautifulSoup(facultyHtml)
# print(soup.prettify())
headers = soup.select('html.no-js body')
# # names = []
# # for item in [item.string for item in article.select('h6 a')]:
# #     if not '@umbc.edu' in item: names.append(item)

# qualifiedNames, researchDescriptions = [], []
# for item in article.select('h6'):
#     if item.text:
#         qualifiedNames.append(unicodedata.normalize("NFKD", item.text))    
#         researchDescriptions.append(unicodedata.normalize("NFKD", item.next_sibling.next_sibling.text))
# data = dict(zip(qualifiedNames, researchDescriptions))
# df = pd.DataFrame([qualifiedNames, researchDescriptions]).T
# df.columns = ['qualifiedNames', 'researchDescriptions']
# df.to_csv('crawled-data/faculty.csv')
# END parseFaculty()
    
# def parseProjects():
# with open('raw-data/current-extramural-funded-projects.html', encoding='utf-8') as f: projectsHtml = f.read()
# soup = BeautifulSoup(projectsHtml)
# article = soup.select('body#home div#container section.page-container.layout-default section.page-content section.main-content article')[0]
# data = []
# for item in article.select('h4'):
#     current = item
#     infos = []
#     while True:
#         try:
#             if current.text:
#                 infos.append(unicodedata.normalize("NFKD", current.text))
#                 if len(infos) == 5: break
#         except AttributeError: pass
#         current = current.next_sibling
#     data.append(infos)
# df = pd.DataFrame(data)
# df.columns = ['title', 'soruce', 'principalInvestigator', 'awarded', 'description']
# df.to_csv('crawled-data/projects.csv')
# END parseProjects()