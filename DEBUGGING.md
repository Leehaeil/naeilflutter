# 디버깅 가이드

## 프로세스가 종료되지 않는 문제

### 원인 가능성
1. 파일 복사 중 블로킹
2. `interact_cli`의 stdin 처리 문제
3. 특정 파일 권한 문제

### 해결 방법

#### 1. 수동 종료
프로세스가 멈춰있으면:
```bash
# Ctrl+C로 강제 종료
# 또는
pkill -f "dart.*naeileun"
```

#### 2. 상세 로그 확인
코드에 추가된 로깅을 확인:
- 파일 복사 진행 상황 (10개마다 출력)
- 각 단계별 완료 메시지
- 예외 발생 시 스택 트레이스

#### 3. 단계별 테스트
```bash
# 1. 기본 명령어만 테스트
dart run bin/naeileun.dart flutter init

# 2. 프로젝트 생성만 확인 (sample 복사 전)
# FlutterRunner.createProject() 후 멈추는지 확인

# 3. sample 복사만 확인
# ProjectInitializer.initialize()에서 멈추는지 확인
```

#### 4. 파일 권한 확인
```bash
# sample 폴더 권한 확인
ls -la sample/

# 생성된 프로젝트 폴더 권한 확인
ls -la <프로젝트명>/
```

#### 5. 큰 파일 확인
sample 폴더에 큰 파일이 있는지 확인:
```bash
find sample -type f -size +10M
```

### 개선 사항
- ✅ 명시적 `exit(0)` 호출
- ✅ 예외 처리 강화
- ✅ 파일 복사 진행 상황 로깅
- ✅ 스택 트레이스 출력

### 다음 단계
문제가 계속되면:
1. 어느 단계에서 멈추는지 확인 (로그 메시지 확인)
2. 생성된 프로젝트 폴더 확인
3. 에러 메시지나 스택 트레이스 확인

