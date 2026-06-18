# 📂 프로젝트 구조

Skindiagnosis 프로젝트의 전체 파일 구조와 각 파일의 역할을 설명합니다.

---

## 📁 전체 디렉토리 구조

```
Skindiagnosis/
├── 📄 README.md                          # 프로젝트 개요 및 사용 가이드
├── 📄 QUICKSTART.md                      # 빠른 시작 가이드 (5분 내 실행)
├── 📄 ARCHITECTURE.md                    # 상세 아키텍처 문서
├── 📄 DEVELOPMENT_GUIDE.md               # 개발자 가이드
├── 📄 CHANGELOG.md                       # 변경 이력
├── 📄 PROJECT_STRUCTURE.md               # 이 문서
│
└── Skindiagnosis/                            # Xcode 프로젝트 루트
    ├── Skindiagnosis.xcodeproj/              # Xcode 프로젝트 파일
    │   ├── project.pbxproj
    │   └── project.xcworkspace/
    │
    ├── Skindiagnosis/                        # 메인 소스 코드
    │   │
    │   ├── 🚀 SkindiagnosisApp.swift         # 앱 진입점 (Dependency Injection)
    │   │
    │   ├── 🎯 Domain/                    # 도메인 계층 (비즈니스 로직)
    │   │   ├── Entities/                 # 엔티티 (데이터 모델)
    │   │   │   └── SkinAnalysisResult.swift
    │   │   └── UseCases/                 # 유즈케이스 (비즈니스 로직)
    │   │       └── AnalyzeSkinUseCase.swift
    │   │
    │   ├── 💾 Data/                      # 데이터 계층 (외부 데이터 소스)
    │   │   └── Services/                 # 서비스 (ML, API 등)
    │   │       └── MLInferenceService.swift
    │   │
    │   ├── 📱 Presentation/              # 프레젠테이션 계층 (UI)
    │   │   ├── Views/                    # SwiftUI 뷰
    │   │   │   ├── SkindiagnosisView.swift   # 메인 화면
    │   │   │   └── Components/           # 재사용 컴포넌트
    │   │   │       ├── WarningPopup.swift
    │   │   │       ├── ResultCard.swift
    │   │   │       └── CameraView.swift
    │   │   └── ViewModels/               # 뷰모델 (MVVM)
    │   │       └── SkindiagnosisViewModel.swift
    │   │
    │   ├── 🎨 Resources/                 # 리소스 파일
    │   │   └── AppColors.swift           # 색상 팔레트
    │   │
    │   ├── Assets.xcassets/              # 이미지 및 색상 에셋
    │   │   ├── AppIcon.appiconset/
    │   │   ├── AccentColor.colorset/
    │   │   └── Contents.json
    │   │
    │   ├── ContentView.swift             # (사용 안 함, 초기 템플릿)
    │   ├── Persistence.swift             # (사용 안 함, 초기 템플릿)
    │   └── Skindiagnosis.xcdatamodeld/       # (사용 안 함, 초기 템플릿)
    │
    ├── SkindiagnosisTests/                   # Unit Tests
    │   └── SkindiagnosisTests.swift
    │
    └── SkindiagnosisUITests/                 # UI Tests
        ├── SkindiagnosisUITests.swift
        └── SkindiagnosisUITestsLaunchTests.swift
```

---

## 🗂️ 파일별 상세 설명

### 📄 루트 문서 파일들

| 파일 | 목적 | 언제 읽어야 하나요? |
|-----|------|------------------|
| `README.md` | 프로젝트 개요, 기능 소개, 설치 방법 | 프로젝트를 처음 접할 때 |
| `QUICKSTART.md` | 5분 내 앱 실행 가이드 | 바로 실행해보고 싶을 때 |
| `ARCHITECTURE.md` | Clean Architecture 상세 설명 | 아키텍처를 이해하고 싶을 때 |
| `DEVELOPMENT_GUIDE.md` | 개발 환경 설정, 코드 스타일, ML 통합 | 개발을 시작할 때 |
| `CHANGELOG.md` | 버전별 변경 이력 | 업데이트 내역을 확인할 때 |
| `PROJECT_STRUCTURE.md` | 이 문서 | 파일 구조를 파악하고 싶을 때 |

---

### 🚀 앱 진입점

#### `SkindiagnosisApp.swift`

**역할**: 앱의 시작점, 의존성 주입

```swift
@main
struct SkindiagnosisApp: App {
    // 의존성 생성 (최상위에서 관리)
    private let mlService: MLInferenceServiceProtocol = MockMLInferenceService()
    
    var body: some Scene {
        WindowGroup {
            // 의존성 주입 체인
            let useCase = AnalyzeSkinUseCase(mlService: mlService)
            let viewModel = SkindiagnosisViewModel(analyzeSkinUseCase: useCase)
            SkindiagnosisView(viewModel: viewModel)
        }
    }
}
```

**책임**:
- ✅ 앱 라이프사이클 관리
- ✅ 의존성 주입 (DI Container 역할)
- ✅ 루트 뷰 설정

**수정 필요 시점**:
- ML 모델 교체 시 (Mock → Real)
- 새로운 전역 의존성 추가 시

---

### 🎯 Domain Layer (비즈니스 로직)

#### `Domain/Entities/SkinAnalysisResult.swift`

**역할**: 피부 분석 결과 데이터 모델

```swift
struct SkinAnalysisResult {
    let image: UIImage
    let classificationType: ClassificationType  // .benign or .malignant
    let malignantProbability: Double            // 0.0 ~ 1.0
    let analyzedAt: Date
    
    var probabilityPercentage: Int              // 0 ~ 100
    var needsSecondaryCheckup: Bool             // ≥80%
}
```

**특징**:
- 📦 불변 구조체 (Value Type)
- 🧮 비즈니스 규칙 캡슐화 (`needsSecondaryCheckup`)
- 🔌 프레임워크 독립적

**사용처**:
- ✅ ViewModel에서 결과 저장
- ✅ View에서 결과 표시
- ✅ Repository에서 히스토리 저장 (향후)

---

#### `Domain/UseCases/AnalyzeSkinUseCase.swift`

**역할**: 피부 이미지 분석 비즈니스 로직

```swift
class AnalyzeSkinUseCase {
    private let mlService: MLInferenceServiceProtocol
    
    func execute(image: UIImage) async throws -> SkinAnalysisResult {
        // 1. ML 모델로 확률 예측
        let probability = try await mlService.predict(image: image)
        
        // 2. 비즈니스 규칙 적용 (50% 기준 분류)
        let type: ClassificationType = probability >= 0.5 ? .malignant : .benign
        
        // 3. 결과 엔티티 생성
        return SkinAnalysisResult(...)
    }
}
```

**책임**:
- ✅ ML 서비스 호출
- ✅ 분류 로직 적용
- ✅ 엔티티 생성

**비즈니스 규칙**:
- 악성 확률 ≥ 50% → 악성 의심
- 악성 확률 < 50% → 양성

---

### 💾 Data Layer (데이터 처리)

#### `Data/Services/MLInferenceService.swift`

**역할**: ML 모델 추론 서비스

**구성**:
1. **Protocol**: `MLInferenceServiceProtocol`
   ```swift
   protocol MLInferenceServiceProtocol {
       func predict(image: UIImage) async throws -> Double
   }
   ```

2. **Mock Implementation**: `MockMLInferenceService`
   - 개발 단계에서 사용
   - 3가지 시뮬레이션 모드 (.random, .highRisk, .lowRisk)
   - 1~2초 네트워크 지연 시뮬레이션

3. **Real Implementation**: `RealMLInferenceService` (주석으로 가이드 제공)
   - TODO: CoreML 모델 추가 후 구현
   - UIImage → CVPixelBuffer 변환
   - Vision 프레임워크 사용

**교체 방법**:
```swift
// SkindiagnosisApp.swift

// Before (개발)
private let mlService = MockMLInferenceService()

// After (배포)
private let mlService = try! RealMLInferenceService()
```

---

### 📱 Presentation Layer (UI)

#### `Presentation/ViewModels/SkindiagnosisViewModel.swift`

**역할**: 메인 화면의 상태 및 비즈니스 로직 관리 (MVVM 패턴)

**Published 상태**:
```swift
@Published var loadingState: LoadingState              // 로딩 상태
@Published var analysisResult: SkinAnalysisResult?     // 분석 결과
@Published var showWarningPopup: Bool                  // 경고 팝업 표시
@Published var selectedImage: UIImage?                 // 선택된 이미지
```

**주요 메서드**:
- `analyzeSkin()`: 피부 분석 실행
- `startNewAnalysis()`: 상태 초기화
- `dismissWarning()`: 경고 팝업 닫기
- `setImageFromCamera(_:)`: 카메라 이미지 설정

**데이터 플로우**:
```
User Action
    ↓
View (Button Tap)
    ↓
ViewModel.analyzeSkin()
    ↓
UseCase.execute()
    ↓
ML Service.predict()
    ↓
ViewModel (@Published 업데이트)
    ↓
View (자동 리렌더링)
```

---

#### `Presentation/Views/SkindiagnosisView.swift`

**역할**: 메인 화면 UI (Toss 스타일)

**화면 구성**:
```
┌─────────────────────────────┐
│ headerView                  │  ← 제목 영역
├─────────────────────────────┤
│                             │
│ mainContentView             │  ← 상태별 컨텐츠
│ (idle/loading/success/error)│
│                             │
├─────────────────────────────┤
│ actionButtonsView           │  ← 버튼 영역
└─────────────────────────────┘
```

**상태별 UI**:

| State | View | 주요 컴포넌트 |
|-------|------|-------------|
| `idle` | `idleStateView` | 이미지 선택 플레이스홀더 |
| `loading` | `loadingStateView` | ProgressView + 반투명 오버레이 |
| `success` | `ResultCard` | 분석 결과 카드 |
| `error` | `errorStateView` | 에러 메시지 |

**애니메이션**:
```swift
.transition(.scale.combined(with: .opacity))
.animation(.spring(response: 0.4, dampingFraction: 0.8))
```

---

#### `Presentation/Views/Components/WarningPopup.swift`

**역할**: 80% 이상 악성 확률일 때 경고 팝업

**표시 조건**:
```swift
if result.needsSecondaryCheckup {  // ≥80%
    showWarningPopup = true
}
```

**디자인 요소**:
- ⚠️ 경고 아이콘
- 📊 확률 표시
- 📝 안내 메시지
- 🔘 확인 버튼

**애니메이션**:
- Scale + Opacity transition
- Spring 효과 (부드러운 등장)

---

#### `Presentation/Views/Components/ResultCard.swift`

**역할**: 분석 결과를 표시하는 카드 컴포넌트

**레이아웃**:
```
┌──────────────────────┐
│   [분석된 이미지]      │  ← 280pt 높이
│                      │
│      분석 결과        │
│      악성 의심        │  ← 색상 구분
│                      │
│      악성 확률        │
│        86%           │  ← 48pt 폰트
│                      │
│ 전문의 상담을 권장...  │
└──────────────────────┘
```

**색상 규칙**:
- `benign` → `AppColors.benign` (#00C471 그린)
- `malignant` → `AppColors.malignant` (#FF6B6B 레드)

---

#### `Presentation/Views/Components/CameraView.swift`

**역할**: UIKit 카메라를 SwiftUI에서 사용하기 위한 래퍼

**구현**:
```swift
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController() -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        return picker
    }
}
```

**사용처**:
```swift
.sheet(isPresented: $viewModel.showCamera) {
    CameraView { image in
        viewModel.setImageFromCamera(image)
    }
}
```

---

### 🎨 Resources

#### `Resources/AppColors.swift`

**역할**: 앱 전체 색상 팔레트 관리

**정의된 색상**:

| 색상 | Hex | 용도 |
|-----|-----|------|
| `primary` | #3182F6 | 메인 버튼, 액센트 |
| `benign` | #00C471 | 양성 결과 |
| `malignant` | #FF6B6B | 악성 결과 |
| `textPrimary` | #191F28 | 주요 텍스트 |
| `textSecondary` | #6B7684 | 보조 텍스트 |
| `textTertiary` | #B0B8C1 | 비활성 텍스트 |
| `background` | #FFFFFF | 배경 |
| `cardBackground` | #F9FAFB | 카드 배경 |
| `divider` | #E5E8EB | 구분선 |

**사용 예시**:
```swift
Text("제목")
    .foregroundColor(AppColors.textPrimary)

Button("버튼") { }
    .background(AppColors.primary)
```

**색상 확장**:
```swift
extension Color {
    init(hex: String) {
        // Hex 문자열을 SwiftUI Color로 변환
    }
}
```

---

## 🔄 데이터 흐름 다이어그램

### 사용자 시나리오: 이미지 분석

```
┌─────────────┐
│    User     │
│  (사진 선택)  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│   SkindiagnosisView         │
│   - PhotosPicker        │
│   - "분석 시작" 버튼      │
└──────┬──────────────────┘
       │ Button Tap
       ▼
┌─────────────────────────┐
│ SkindiagnosisViewModel      │
│ - analyzeSkin()         │
│ - loadingState 변경      │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ AnalyzeSkinUseCase      │
│ - execute(image:)       │
│ - 비즈니스 규칙 적용      │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ MLInferenceService      │
│ (Mock or Real)          │
│ - predict(image:)       │
└──────┬──────────────────┘
       │ 확률 반환 (0.0~1.0)
       ▼
┌─────────────────────────┐
│ AnalyzeSkinUseCase      │
│ - SkinAnalysisResult 생성│
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ SkindiagnosisViewModel      │
│ - @Published 업데이트    │
│ - 경고 팝업 표시 결정     │
└──────┬──────────────────┘
       │ State Changed
       ▼
┌─────────────────────────┐
│   SkindiagnosisView         │
│   (자동 리렌더링)         │
│   - ResultCard 표시      │
│   - WarningPopup (80%+) │
└─────────────────────────┘
```

---

## 🏗️ 계층별 의존성 그래프

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│                                         │
│  SkindiagnosisView ──→ SkindiagnosisViewModel   │
│       ↓                    ↓            │
│  Components        AnalyzeSkinUseCase   │
│  - WarningPopup            ↓            │
│  - ResultCard    ┌─────────────────┐    │
│  - CameraView    │  Domain Layer   │    │
│                  │                 │    │
│                  │ Entities:       │    │
│                  │ - SkinAnalysis  │    │
│                  │   Result        │    │
│                  │                 │    │
│                  │ UseCases:       │    │
│                  │ - AnalyzeSkin   │    │
│                  │   UseCase       │    │
│                  └────────┬────────┘    │
│                           ↓             │
│                  ┌─────────────────┐    │
│                  │   Data Layer    │    │
│                  │                 │    │
│                  │ Services:       │    │
│                  │ - MLInference   │    │
│                  │   Service       │    │
│                  └─────────────────┘    │
└─────────────────────────────────────────┘

의존성 방향: Presentation → Domain → Data
```

---

## 📊 파일 통계

### 코드 라인 수 (대략)

| 계층 | 파일 수 | 예상 라인 수 |
|-----|--------|------------|
| Domain | 2 | ~200 lines |
| Data | 1 | ~200 lines |
| Presentation | 5 | ~800 lines |
| Resources | 1 | ~50 lines |
| **Total** | **9** | **~1,250 lines** |

### 파일 타입별 분포

```
Swift 파일: 9개
  - Views: 4개
  - ViewModels: 1개
  - Entities: 1개
  - UseCases: 1개
  - Services: 1개
  - Resources: 1개

문서 파일: 6개
  - README.md
  - QUICKSTART.md
  - ARCHITECTURE.md
  - DEVELOPMENT_GUIDE.md
  - CHANGELOG.md
  - PROJECT_STRUCTURE.md
```

---

## 🔍 파일 검색 가이드

### "이미지 분석 로직은 어디에?"

→ `Domain/UseCases/AnalyzeSkinUseCase.swift`

### "UI 컴포넌트는 어디에?"

→ `Presentation/Views/Components/`

### "색상 변경하고 싶어요"

→ `Resources/AppColors.swift`

### "ML 모델 통합은 어떻게?"

→ `Data/Services/MLInferenceService.swift` + `DEVELOPMENT_GUIDE.md`

### "분석 결과 구조는?"

→ `Domain/Entities/SkinAnalysisResult.swift`

### "메인 화면 수정은?"

→ `Presentation/Views/SkindiagnosisView.swift`

### "ViewModel 로직은?"

→ `Presentation/ViewModels/SkindiagnosisViewModel.swift`

---

## 🗺️ 개발 로드맵별 파일 수정 계획

### Phase 1: 실제 ML 모델 통합

**수정 파일**:
- ✏️ `Data/Services/MLInferenceService.swift` - `RealMLInferenceService` 구현
- ✏️ `SkindiagnosisApp.swift` - Mock → Real 교체

### Phase 2: 분석 히스토리 기능

**추가 파일**:
- ➕ `Domain/Entities/AnalysisHistory.swift`
- ➕ `Data/Repositories/HistoryRepository.swift`
- ➕ `Presentation/Views/HistoryListView.swift`
- ➕ `Presentation/ViewModels/HistoryViewModel.swift`

### Phase 3: 서버 연동

**추가 파일**:
- ➕ `Data/Network/APIService.swift`
- ➕ `Data/Network/Endpoints.swift`
- ➕ `Data/Repositories/RemoteAnalysisRepository.swift`

**수정 파일**:
- ✏️ `Domain/UseCases/AnalyzeSkinUseCase.swift` - Repository 주입

---

## 📝 코딩 컨벤션

### 파일 네이밍

```
✅ PascalCase.swift
   - SkindiagnosisView.swift
   - SkindiagnosisViewModel.swift
   - AnalyzeSkinUseCase.swift

❌ camelCase.swift, snake_case.swift
```

### 디렉토리 구조

```
✅ 계층별 분리
   Domain/
   Data/
   Presentation/

✅ 기능별 그룹핑
   Views/Components/
   Domain/Entities/
   Domain/UseCases/
```

### import 순서

```swift
// 1. 시스템 프레임워크
import SwiftUI
import UIKit

// 2. 서드파티 라이브러리
// import Alamofire

// 3. 내부 모듈
// import SkindiagnosisCore
```

---

## 🎯 다음에 읽어야 할 문서

1. **새로운 개발자**
   - → [QUICKSTART.md](QUICKSTART.md) (앱 실행)
   - → [ARCHITECTURE.md](ARCHITECTURE.md) (아키텍처 이해)
   - → [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) (개발 시작)

2. **기능 추가**
   - → [ARCHITECTURE.md](ARCHITECTURE.md) (계층 이해)
   - → [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) (코드 스타일)

3. **ML 모델 통합**
   - → [DEVELOPMENT_GUIDE.md - ML 모델 통합](DEVELOPMENT_GUIDE.md#ml-모델-통합)
   - → `Data/Services/MLInferenceService.swift` (주석 참고)

---

**마지막 업데이트**: 2026-02-02
