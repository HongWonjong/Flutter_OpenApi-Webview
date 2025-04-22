# Flutter_OpenApi-Webview

위치 기반 주소 검색 앱
이 프로젝트는 Flutter로 개발된 위치 기반 주소 검색 애플리케이션입니다. 
사용자의 현재 위치를 기반으로 주소를 검색하고, 검색된 주소의 세부 정보를 웹뷰를 통해 표시하는 기능을 제공합니다. 
VWORLD API를 사용해 주소를 검색하고, Naver Search API를 통해 주소와 관련된 웹 검색 결과를 가져옵니다.



외부 API:
VWORLD API (Geolovator 패키지로 디바이스의 위도-경도를 찾은 후, API를 통해 주변 장소를 검색)
Naver Search API (웹 검색 결과)
GeoLocation API(별도의 방법으로 현재 위치 파악) => 추가적인 OPEN API를 적용해 보았음.
