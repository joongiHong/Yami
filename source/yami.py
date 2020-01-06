# 임포트 부분
import requests
import json

# ~~ 학교 코드를 받아오는 부분 ~~


# 1. 학교 목록 불러오기

def school_find(name):
    url = 'https://www.schoolcodekr.ml/api?q=' + name  # 학교코드 API 주소
    response = requests.get(url)
    school_info = json.loads(response.text)
    print(school_info)
