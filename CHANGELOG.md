## 0.0.3

* 템플릿 기반 코드 생성으로 변경 (sample 폴더 불필요)
* 프로젝트 구조 변경: `lib/app/` → `lib/mobile/` 및 `lib/web/` 완전 분리
* 모바일과 웹 코드를 독립적으로 관리하는 아키텍처 적용
* 페이지 추가 명령어가 새로운 구조(`lib/mobile/`, `lib/web/`)에 맞게 업데이트
* 플랫폼별 저장소 구현 분리 (모바일: FlutterSecureStorage, 웹: 쿠키 기반)

## 0.0.2

* 명령어 이름 변경: `naeileun` → `naeil`
* 실행 파일 이름 개선

## 0.0.1

* Flutter 프로젝트 초기화 명령어 (`naeil flutter init`) 추가
  * 프로젝트 이름, 패키지 ID 입력
  * 플랫폼 선택 (android, ios, web, windows, macos, linux)
  * GetX 기반 프로젝트 구조 자동 생성
* Flutter 페이지 추가 명령어 (`naeil flutter addpage`) 추가
  * 페이지 이름 입력 및 컨트롤러 사용 여부 선택
  * 웹 플랫폼 활성화 시 앱/웹 선택
  * View, Controller, Binding 파일 자동 생성
  * 라우팅 파일 자동 업데이트
