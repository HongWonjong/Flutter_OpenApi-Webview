# Flutter_OpenApi-Webview


develop 브랜치에서 코드를 짠 후 정상 작동 확인되면 main으로 pull request 후 merge
<예상 디렉터리 구조>
main.dart // 엔트리 포인트
├──pages
└──adress_list_page.dart
└──webview_page.dart
├──models
└──adress_model.dart
└──web_result_model.dart
└──geolocation_model.dart // GeoLocation API 응답 모델
├──repositories
└──address_repository.dart
└──webview_url_repository.dart
└──geolocation_repository.dart // GeoLocation API 호출
├──providers
└──address_provider.dart
└──webview_url_provider.dart
└──geolocation_provider.dart // 현재 위치 상태 관리
├──components
└──search_text_field.dart
└──address_list_item.dart
└──location_button.dart # 현재 위치 가져오기 버튼
├──styles
└──app_colors.dart // 앱 메인 테마
└──app_font_sizes.dart // 앱 공용 폰트 사이즈