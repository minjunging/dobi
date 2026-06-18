# 변경 이력 (Changelog)

모든 주목할 만한 변경 사항은 이 파일에 기록됩니다.

---

## [1.0.0] - 2026-02-02

### 🎉 초기 릴리스 (MVP)

#### ✨ 추가된 기능

##### Domain Layer
- **SkinAnalysisResult** 엔티티 생성
  - 피부 분석 결과 데이터 모델
  - 양성/악성 분류 타입
  - 악성 확률 저장
  - 2차 검진 필요 여부 계산 로직

- **AnalyzeSkinUseCase** 유즈케이스
  - 피부 이미지 분석 비즈니스 로직
  - 50% 기준 분류 규칙 적용
  - 의존성 주입 패턴 적용

##### Data Layer
- **MLInferenceService** (Mock)
  - Mock ML 추론 서비스 구현
  - 3가지 시뮬레이션 모드 지원
    - Random: 랜덤 확률
    - HighRisk: 항상 높은 위험도 (테스트용)
    - LowRisk: 항상 낮은 위험도
  - UIImage → CVPixelBuffer 변환 유틸리티

##### Presentation Layer
- **SkinCheckView** 메인 화면
  - Toss 스타일 미니멀 UI
  - 4가지 상태별 UI 분기 (idle, loading, success, error)
  - 스프링 애니메이션 적용
  - 사진 선택/카메라 촬영 지원

- **SkinCheckViewModel**
  - MVVM 패턴 적용
  - 비동기 이미지 분석 처리
  - 상태 관리 (@Published)
  - 경고 팝업 자동 표시 로직

- **WarningPopup** 컴포넌트
  - 80% 이상 경고 팝업
  - 모달 카드 디자인
  - Scale + Opacity 애니메이션

- **ResultCard** 컴포넌트
  - 분석 결과 표시 카드
  - 색상 구분 (양성: 그린, 악성: 레드)
  - 확률 퍼센트 표시

- **CameraView** 컴포넌트
  - UIImagePickerController 래퍼
  - 카메라 촬영 기능

##### Resources
- **AppColors** 색상 시스템
  - Toss 스타일 색상 팔레트
  - Hex 코드 → SwiftUI Color 변환 유틸리티
  - 8가지 시맨틱 컬러 정의

##### 아키텍처
- **Clean Architecture** 3-Layer 설계
  - Domain, Data, Presentation 계층 분리
  - 의존성 역전 원칙 (DIP) 적용
  - Protocol 기반 추상화

- **MVVM 패턴** 적용
  - View와 비즈니스 로직 분리
  - ViewModel을 통한 상태 관리

##### 문서
- **README.md**: 프로젝트 개요 및 사용 가이드
- **ARCHITECTURE.md**: 상세 아키텍처 문서
  - 계층별 설명
  - 데이터 흐름 다이어그램
  - 의존성 주입 가이드
- **DEVELOPMENT_GUIDE.md**: 개발자 가이드
  - 개발 환경 설정
  - 코드 스타일 가이드
  - ML 모델 통합 방법
  - 트러블슈팅
- **CHANGELOG.md**: 변경 이력

#### 🎨 디자인
- Toss 스타일 미니멀 UI/UX
- 큰 여백과 명확한 타이포그래피
- 부드러운 스프링 애니메이션
- 직관적인 단일 화면 플로우

#### 🔧 기술 스택
- Swift 5.9
- SwiftUI
- async/await (비동기 처리)
- PhotosUI (이미지 선택)
- UIKit (카메라)

---

## [Unreleased] - 향후 계획

### 📋 TODO

#### v1.1 (다음 버전)
- [ ] 실제 CoreML 모델 통합
  - RealMLInferenceService 구현
  - Vision 프레임워크 적용
  - 성능 최적화

- [ ] 분석 히스토리 기능
  - CoreData 또는 SwiftData 통합
  - 히스토리 목록 화면
  - 결과 상세보기 화면

- [ ] 다국어 지원
  - 영어 (English)
  - Localizable.strings 생성

- [ ] 접근성 개선
  - VoiceOver 지원
  - Dynamic Type 지원
  - 색상 대비 개선

#### v1.2
- [ ] 다크 모드 완전 지원
- [ ] iPad 레이아웃 최적화
- [ ] 앱 아이콘 및 스플래시 화면
- [ ] 온보딩 화면

#### v2.0 (장기)
- [ ] 서버 연동
  - RESTful API 통합
  - 이미지 업로드 및 클라우드 분석
  - 사용자 인증

- [ ] 전문의 상담 연결
  - 병원 찾기 기능
  - 예약 시스템 연동

- [ ] Apple Health 연동
  - 건강 데이터 기록
  - 트렌드 분석

- [ ] 위젯 지원
  - 최근 분석 결과 표시
  - 검진 알림

---

## 버전 관리 규칙

이 프로젝트는 [Semantic Versioning](https://semver.org/) 을 따릅니다:

```
MAJOR.MINOR.PATCH

- MAJOR: 호환되지 않는 API 변경
- MINOR: 기능 추가 (하위 호환)
- PATCH: 버그 수정 (하위 호환)
```

---

## 기여자

- 신종원 ([@sinjong-won](https://github.com/sinjong-won)) - 초기 개발

---

**Legend**:
- ✨ 새 기능
- 🐛 버그 수정
- 🔧 기술적 변경
- 📝 문서
- 🎨 UI/UX
- ⚡️ 성능 개선
- 🔒 보안
- 🧪 테스트
