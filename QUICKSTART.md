# 🚀 빠른 시작 가이드

5분 안에 SkinCheck 앱을 실행해보세요!

---

## ⚡️ 3단계로 시작하기

### 1️⃣ Xcode에서 프로젝트 열기

```bash
cd /Users/sinjong-won/ted.urssu/SkinCheck
open Skincheck/Skincheck.xcodeproj
```

---

### 2️⃣ 권한 설정 추가

Xcode가 열리면:

1. 좌측 네비게이터에서 **Skincheck** 프로젝트 클릭
2. **TARGETS** → **Skincheck** 선택
3. **Info** 탭 클릭
4. **Custom iOS Target Properties** 섹션에서 `+` 버튼 클릭
5. 다음 2개 항목 추가:

#### 첫 번째 권한
- **Key**: `Privacy - Camera Usage Description`
- **Value**: `피부 병변 촬영을 위해 카메라 접근 권한이 필요합니다.`

#### 두 번째 권한
- **Key**: `Privacy - Photo Library Usage Description`
- **Value**: `피부 병변 이미지를 선택하기 위해 사진 라이브러리 접근 권한이 필요합니다.`

![권한 설정 예시](https://via.placeholder.com/800x200/3182F6/FFFFFF?text=Xcode+Info+Tab+%E2%86%92+%2B+%E2%86%92+Add+Privacy+Keys)

---

### 3️⃣ 실행하기

1. 시뮬레이터 선택: **iPhone 15 Pro** (권장)
2. **Cmd + R** 누르기 또는 ▶️ 버튼 클릭
3. 앱이 실행됩니다! 🎉

---

## 📱 앱 사용해보기

### 시나리오 1: 사진 라이브러리에서 선택

1. 앱 실행
2. **"사진 선택"** 버튼 탭
3. 시뮬레이터 사진 라이브러리에서 이미지 선택
4. **"분석 시작"** 버튼 탭
5. 1~2초 후 결과 확인! ✅

### 시나리오 2: 실제 기기에서 카메라 촬영

> ⚠️ 카메라는 실제 iPhone/iPad에서만 작동합니다

1. iPhone을 Mac에 연결
2. Xcode에서 디바이스 선택 (시뮬레이터 → 내 iPhone)
3. **Cmd + R** 실행
4. 앱에서 **"촬영"** 버튼 탭
5. 카메라로 피부 부위 촬영
6. **"분석 시작"** 버튼 탭
7. 결과 확인!

---

## 🧪 테스트 모드 변경

경고 팝업을 바로 보고 싶다면?

### 고위험 모드 활성화

`SkincheckApp.swift` 파일 열기:

```swift
// 현재 (랜덤 모드)
private let mlService: MLInferenceServiceProtocol = MockMLInferenceService(mode: .random)

// 변경 (항상 80% 이상)
private let mlService: MLInferenceServiceProtocol = MockMLInferenceService(mode: .highRisk)
```

**Cmd + R** 로 재실행하면 항상 경고 팝업이 표시됩니다!

---

## 🎨 화면별 미리보기

### 1. 시작 화면 (Idle State)

```
┌─────────────────────────────┐
│       SkinCheck             │
│   피부 병변 위험도 검사      │
│                             │
│   ┌─────────────────────┐   │
│   │                     │   │
│   │   📷 사진 선택       │   │
│   │                     │   │
│   └─────────────────────┘   │
│                             │
│  [사진 선택]  [촬영]         │
│     [분석 시작]              │
└─────────────────────────────┘
```

### 2. 로딩 화면 (Loading State)

```
┌─────────────────────────────┐
│       SkinCheck             │
│   피부 병변 위험도 검사      │
│                             │
│   ┌─────────────────────┐   │
│   │      [이미지]        │   │
│   │                     │   │
│   │   ⏳ 분석 중...      │   │
│   │                     │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
```

### 3. 결과 화면 (Success State)

```
┌─────────────────────────────┐
│       SkinCheck             │
│   피부 병변 위험도 검사      │
│                             │
│   ┌─────────────────────┐   │
│   │    [분석 이미지]     │   │
│   │                     │   │
│   │    분석 결과         │   │
│   │    악성 의심  ⚠️     │   │
│   │                     │   │
│   │    악성 확률         │   │
│   │      86% 📊         │   │
│   │                     │   │
│   │ 전문의 상담을 권장... │   │
│   └─────────────────────┘   │
│                             │
│   [새로운 검사 시작]         │
└─────────────────────────────┘
```

### 4. 경고 팝업 (80% 이상)

```
┌─────────────────────────────┐
│   [반투명 배경]              │
│                             │
│   ┌─────────────────────┐   │
│   │                     │   │
│   │       ⚠️            │   │
│   │                     │   │
│   │   2차 검진 권장      │   │
│   │   악성 확률: 86%     │   │
│   │                     │   │
│   │ 전문의 상담을 통한   │   │
│   │ 정확한 진단을 권장... │   │
│   │                     │   │
│   │  [확인했습니다]      │   │
│   │                     │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
```

---

## 🐛 문제 해결

### Q: "카메라를 사용할 수 없습니다" 에러

**A**: 권한 설정이 누락되었습니다.

1. [2️⃣ 권한 설정 추가](#2️⃣-권한-설정-추가) 단계 다시 확인
2. 앱 삭제 후 재설치
3. iPhone 설정 → Skincheck → 카메라 권한 확인

---

### Q: 시뮬레이터에서 카메라 버튼이 작동하지 않음

**A**: 시뮬레이터는 카메라를 지원하지 않습니다.

**해결**:
- "사진 선택" 버튼을 사용하세요
- 또는 실제 iPhone에서 테스트하세요

---

### Q: 빌드 에러 발생

**A**: Xcode 버전 확인

- **Xcode 15.0 이상** 필요
- Swift 5.9 이상

**해결**:
```bash
# Xcode 버전 확인
xcodebuild -version

# 최신 Xcode 설치
# App Store → Xcode 업데이트
```

---

### Q: "분석 시작" 버튼이 비활성화됨

**A**: 이미지를 먼저 선택해야 합니다.

1. "사진 선택" 또는 "촬영" 버튼 클릭
2. 이미지 선택 완료
3. "분석 시작" 버튼 활성화 확인

---

## 📚 다음 단계

### 코드 살펴보기

1. **아키텍처 이해하기**
   - [ARCHITECTURE.md](ARCHITECTURE.md) 읽기
   - Clean Architecture 3-Layer 구조 파악

2. **주요 파일 탐색**
   ```
   SkinCheckView.swift          ← 메인 화면 UI
   SkinCheckViewModel.swift     ← 비즈니스 로직
   AnalyzeSkinUseCase.swift     ← 분석 유즈케이스
   MLInferenceService.swift     ← ML 서비스 (Mock)
   ```

3. **개발자 가이드 읽기**
   - [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
   - ML 모델 통합 방법 학습

### 실제 ML 모델 추가하기

1. CoreML 모델 파일(`.mlmodel`) 준비
2. Xcode 프로젝트에 추가
3. `RealMLInferenceService` 구현
4. `SkincheckApp.swift`에서 교체

자세한 방법: [DEVELOPMENT_GUIDE.md - ML 모델 통합](DEVELOPMENT_GUIDE.md#ml-모델-통합)

---

## 🎯 주요 파일 위치

```
Skincheck/Skincheck/
├── SkincheckApp.swift                    ← 🚀 앱 시작점
├── Domain/
│   ├── Entities/
│   │   └── SkinAnalysisResult.swift      ← 📊 결과 데이터 모델
│   └── UseCases/
│       └── AnalyzeSkinUseCase.swift      ← 🎯 비즈니스 로직
├── Data/
│   └── Services/
│       └── MLInferenceService.swift      ← 🤖 ML 서비스
├── Presentation/
│   ├── Views/
│   │   ├── SkinCheckView.swift           ← 📱 메인 화면
│   │   └── Components/
│   │       ├── WarningPopup.swift        ← ⚠️ 경고 팝업
│   │       └── ResultCard.swift          ← 📋 결과 카드
│   └── ViewModels/
│       └── SkinCheckViewModel.swift      ← 🔄 상태 관리
└── Resources/
    └── AppColors.swift                   ← 🎨 색상 팔레트
```

---

## 💡 팁

### 개발 효율성

1. **Xcode Preview 활용**
   ```swift
   #Preview {
       SkinCheckView(viewModel: .preview)
   }
   ```
   - `Cmd + Option + P`: Preview 시작/재시작
   - 실시간으로 UI 변경사항 확인

2. **Hot Reload**
   - SwiftUI는 코드 변경 시 자동 리로드
   - 빠른 UI 개발 가능

3. **시뮬레이션 모드 활용**
   ```swift
   .random    // 랜덤 테스트
   .highRisk  // 경고 팝업 테스트
   .lowRisk   // 양성 결과 테스트
   ```

---

## 📞 도움이 필요하신가요?

- **문서**: [README.md](README.md), [ARCHITECTURE.md](ARCHITECTURE.md)
- **개발 가이드**: [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
- **이슈 리포트**: [GitHub Issues](https://github.com/your-username/SkinCheck/issues)

---

## ⭐️ 프로젝트가 마음에 드셨나요?

이 프로젝트는 Clean Architecture와 SwiftUI 베스트 프랙티스를 보여주는 예제입니다.

**배운 점**:
- ✅ Clean Architecture 3-Layer 설계
- ✅ MVVM 패턴
- ✅ 의존성 주입 (DI)
- ✅ Protocol 기반 추상화
- ✅ async/await 비동기 처리
- ✅ SwiftUI 애니메이션

---

**Happy Coding! 🚀**
