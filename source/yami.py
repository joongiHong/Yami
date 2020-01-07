# 임포트 부분
import requests
import json

# ~~ 학교 코드를 받아오는 부분 ~~


# 1. 학교 목록 불러오기

def school_find(name):
    url = 'https://www.schoolcodekr.ml/api?q=' + name  # 학교코드 API 주소
    response = requests.get(url)  # API에 접속하여 해당 이름을 가진 학교를 불러옵니다.
    school_infos_json = json.loads(response.text)  # json으로 가지고 옵니다.
    school_infos = school_infos_json['school_infos']  # 가져온 내용에서 학교 정보 부분만 분리
    school_infos_count = len(school_infos)  # school_infos에서 불러온 학교 개수 저장

    for i in range(0, school_infos_count):  # 가져온 학교 수 만큼 반복
        school_info = school_infos[i]  # 한 개의 학교 정보만 대입
        school_name = school_info['name']  # 학교 이름을 school_name 변수에 대입
        school_address = school_info['address']  # 학교 주소를 school_address 변수에 대입
        print(str(i) + "번째" +
              "\n학교 이름 : " + school_name +
              "\n학교 주소 : " + school_address)  # 출력


school_find('고창중학교')
