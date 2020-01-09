# 임포트 부분
import requests
import json
from bs4 import BeautifulSoup
import openpyxl
import sys
import csv

hang = 0  # 급식 정보가 있는 행 정보 저장을 위한 전역변수 선언

# ~~ 학교 목록과 코드를 불러오는 파트 ~~


# 1. 학교 목록 불러오기

def school_find(name):
    global school_infos  # 전역변수 사용

    url = 'https://www.schoolcodekr.ml/api?q=' + name  # 학교코드 API 주소
    response = requests.get(url)  # API에 접속하여 해당 이름을 가진 학교를 불러옴
    school_infos_json = json.loads(response.text)  # json으로 가지고 옴
    school_infos = school_infos_json['school_infos']  # 가져온 내용에서 학교 정보 부분만 분리
    school_infos_count = len(school_infos)  # school_infos에서 불러온 학교 개수 저장

    school = ""  # 문자열 합치기를 위한 변수 선언

    for i in range(0, school_infos_count):  # 가져온 학교 수 만큼 반복
        school_info = school_infos[i]  # 한 개의 학교 정보만 대입
        school_name = school_info['name']  # 학교 이름을 school_name 변수에 대입
        school_address = school_info['address']  # 학교 주소를 school_address 변수에 대입
        school = school + str(i) + "번째" +\
            "\n학교 이름 : " + school_name +\
            "\n학교 주소 : " + school_address + "\n"  # 기존의 출력 내용과 신규 내용 합산

    return(school)


# 2. 학교 코드 불러오기

def school_code(name, num):
    num = int(num)
    url = 'https://www.schoolcodekr.ml/api?q=' + name  # 학교코드 API 주소
    response = requests.get(url)  # API에 접속하여 해당 이름을 가진 학교를 불러옴
    school_infos_json = json.loads(response.text)  # json으로 가지고 옴
    school_infos = school_infos_json['school_infos']  # 가져온 내용에서 학교 정보 부분만 분리

    school_info = school_infos[num]  # 불러온 학교 목록에서 num번째 학교 정보 다시 대입
    school_code = school_info['code']  # 해당 학교 정보에서 코드 부분 대입
    return(school_code)  # 반환


# ~~ 학교 급식을 불러오고 저장하는 파트 ~~

# 3. 학교 급식 불러오기

def school_food(ooe, code, ymd, sclass, kindfood):
    url = "http://stu." + ooe + ".go.kr/sts_sci_md01_001.do?" +\
        "schulCode=" + code +\
        "&schulCrseScCode=" + sclass +\
        "&schulKnaScCode=0" + sclass +\
        "&schMmealScCode=" + kindfood +\
        "&schYmd=" + ymd
    # ooe는 교육청, code는 학교고유코드, sclass는 교급, year와 month는 조회 년월

    response = requests.get(url)  # 급식 정보 요청
    if response.status_code != 200:  # 만일 서버 접속 문제시 에러 전달
        return('Server Error')

    foodhtml = BeautifulSoup(response.text, 'html.parser')  # html 파싱을 위한 준비
    foodhtml_data_tr = foodhtml.find_all('tr')

    # 몇번째 행이 데이터 있는지 조회

    foodhtml_date = foodhtml_data_tr[0].find_all('th')  # 날짜 정보가 있는 열 불러옴
    for i in range(1, 8):  # 월요일부터 토요일까지 진행
        global hang
        date = str(foodhtml_date[i])  # i요일 데이터 불러옴
        date_filter = ['<th class="point2" scope="col">', '<th class="last point1" scope="col">',
                       '<th scope="col">', '</th>']
        date_filter2 = ['(', ')', '일', '월', '화', '수', '목', '금', '토']

        for sakje in date_filter:
            date = date.replace(sakje, '')  # 찌끄레기 없애고 필요한 정보만 남김

        date2 = date

        for sakje in date_filter2:
            date2 = date2.replace(sakje, '')

        if date2 != ymd:  # 날짜와 입력날짜가 다를 경우 패스
            continue

        hang = i - 1  # 급식정보가 있는 행 선언
        # origin_ymd = date  # yyyy.mm.dd (요일) 형식 날짜 선언
        break

    # 급식 정보 가져오기

    food = foodhtml_data_tr[2].find_all('td')  # 급식정보가 있는 열 가져오기
    food = str(food[hang])

    food_filter = ['<td class="textC">',
                   '<td class="textC last">', '</td>']

    for sakje in food_filter:
        food = food.replace(sakje, '')  # 찌끄레기 삭제

    food = food.replace('<br/>', '`n')  # html 코드 변환

    if food == ' ':
        food = '급식이 예정되지 않았거나 급식 정보가 없습니다.\n'

    output = [date, food]

    return(output)


# 4. 학교 급식 저장하기 (월간)

def school_food_save(ooe, code, year, month, sclass, kindfood):

    cs = open('Yami_' + year + '_' + month + '.csv',
              'w', encoding='utf-8', newline='')
    wr_cs = csv.writer(cs)

    # 날짜 구하기
    if month == '02':  # 2월 조회시
        if year % 4 == 0 and year % 100 != 0:  # 윤년일 경우 29일이 마지막
            last_day = 29
        elif year % 400 == 0:
            last_day = 29
        else:  # 아니면 28이 마지막
            last_day = 28
    elif month == '01' or month == '03' or month == '05' or month == '07' or month == '08' or month == '10' or month == '12':  # 끝날이 31일 목록
        last_day = 31
    else:
        last_day = 30

    for day in range(1, last_day + 1):  # 하루 씩 day에 대입
        # xday = day  # 엑셀용 날짜 저장
        if day < 10:
            day = '0' + str(day)
        meal = school_food(ooe, code, year + '.' +
                           month + '.' + str(day), sclass, kindfood)  # 급식정보 불러옴

        wr_cs.writerow([meal[0], meal[1]])

    cs.close()

# ~~ 함수를 구분하는 파트 ~~


# 0. 오토핫키 사용을 위한 함수 구분용 함수

def yami(function, para):
    if function == "school_find":
        f = open('school_list.txt', 'w')
        f.write(school_find(para))
        f.close()
        # sys.exit()
    elif function == "school_code":
        f = open('school_code.txt', 'w')
        f.write(school_code(para[0], para[1]))
        f.close()
        # sys.exit()
    elif function == "school_food_save":
        # 교육청, 코드, 년, 월, 교급, 중석식, 아웃풋 파일 설정
        try:
            school_food_save(para[0], para[1], para[2],
                             para[3], para[4], para[5])
            f = open('result.txt', 'w')
            f.write('0')
            f.close()
            # sys.exit()
        except:
            f = open('result.txt', 'w')
            f.write('1')
            f.close()
            # sys.exit()


#yami("school_find", "고창중학교")
#yami("school_code", ["고창중학교", "0"])
yami("school_food_save", ["goe", "J100005611", "2019", "09", "3", "2"])
