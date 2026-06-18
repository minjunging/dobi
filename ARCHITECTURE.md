# Skindiagnosis - 아키텍처 문서

## 개요

Skindiagnosis는 피부 병변의 양성/악성 위험도를 검사하는 iOS 앱입니다.
Clean Architecture 원칙을 따라 설계되었으며, 각 계층이 명확히 분리되어 있습니다.

⚠️ **중요**: 이 앱은 의료 진단 도구가 아닙니다. 2차 검진 필요 여부만 안내합니다.

---

## 아키텍처 구조

### Clean Architecture 3-Layer 설계

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (UI, ViewModel, User Interaction)     │
└────────────────┬────────────────────────┘
                 │ depends on
┌────────────────▼────────────────────────┐
│          Domain Layer                   │
│   (Business Logic, Entities, UseCases)  │
└────────────────┬────────────────────────┘
                 │ depends on
┌────────────────▼────────────────────────┐
│           Data Layer                    │
│    (ML Service, Repositories, API)      │
└─────────────────────────────────────────┘
```

**핵심 원칙**:
- 의존성은 항상 **외부 → 내부**로 향합니다
- Domain Layer는 다른 계층에 의존하지 않습니다
- Interface(Protocol)를 통한 의존성 역전 (DIP)

---

## 프로젝트 구조

```
Skindiagnosis/
├── Domain/                          # 비즈니스 로직 계층
│   ├── Entities/                    # 도메인 엔티티 (데이터 모델)
│   │   └── SkinAnalysisResult.swift # 분석 결과 엔티티
│   └── UseCases/                    # 비즈니스 유즈케이스
│       └── AnalyzeSkinUseCase.swift # 피부 분석 유즈케이스
│
├── Data/                            # 데이터 처리 계층
│   └── Services/                    # 외부 서비스 (ML, API 등)
│       └── MLInferenceService.swift # ML 추론 서비스
│
├── Presentation/                    # 프레젠테이션 계층
│   ├── Views/                       # SwiftUI 뷰
│   │   ├── SkindiagnosisView.swift      # 메인 화면
│   │   └── Components/              # 재사용 가능한 컴포넌트
│   │       ├── WarningPopup.swift   # 경고 팝업
│   │       ├── ResultCard.swift     # 결과 카드
│   │       └── CameraView.swift     # 카메라 뷰
│   └── ViewModels/                  # 뷰모델 (MVVM)
│       └── SkindiagnosisViewModel.swift # 메인 뷰모델
│
├── Resources/                       # 리소스 파일
│   └── AppColors.swift              # 앱 색상 팔레트
│
└── SkindiagnosisApp.swift               # 앱 진입점 (Dependency Injection)
```

---

## 계층별 상세 설명

### 1. Domain Layer (도메인 계층)

**목적**: 비즈니스 로직과 핵심 규칙을 담당

#### 📁 Entities (엔티티)

##### `SkinAnalysisResult.swift`
피부 분석 결과를 담는 핵심 데이터 모델

```swift
struct SkinAnalysisResult {
    let image: UIImage                      // 분석된 이미지
    let classificationType: ClassificationType  // 양성/악성 분류
    let malignantProbability: Double        // 악성 확률 (0.0 ~ 1.0)
    let analyzedAt: Date                    // 분석 시각
    
    var probabilityPercentage: Int          // 퍼센트 표시 (0~100)
    var needsSecondaryCheckup: Bool         // 2차 검진 필요 여부 (≥80%)
}

enum ClassificationType {
    case benign      // 양성
    case malignant   // 악성 의심
}
```

**설계 이유**:
- 불변 구조체로 데이터 안정성 보장
- 비즈니스 규칙 캡슐화 (`needsSecondaryCheckup`)
- 프레임워크 독립적 (UIKit 의존성 최소화 가능)

---

#### 📁 UseCases (유즈케이스)

##### `AnalyzeSkinUseCase.swift`
피부 이미지 분석 비즈니스 로직

```swift
class AnalyzeSkinUseCase {
    private let mlService: MLInferenceServiceProtocol
    
    init(mlService: MLInferenceServiceProtocol) {
        self.mlService = mlService
    }
    
    func execute(image: UIImage) async throws -> SkinAnalysisResult {
        // 1. ML 서비스를 통해 악성 확률 예측
        let probability = try await mlService.predict(image: image)
        
        // 2. 비즈니스 규칙: 50% 기준으로 분류
        let type: ClassificationType = probability >= 0.5 ? .malignant : .benign
        
        // 3. 결과 엔티티 생성
        return SkinAnalysisResult(
            image: image,
            classificationType: type,
            malignantProbability: probability
        )
    }
}
```

**설계 이유**:
- 단일 책임 원칙 (SRP): 하나의 비즈니스 로직만 담당
- 의존성 주입 (DI): 테스트 용이성
- Protocol 기반: Mock으로 교체 가능

---

### 2. Data Layer (데이터 계층)

**목적**: 외부 데이터 소스 (ML 모델, API 등) 관리

#### 📁 Services

##### `MLInferenceService.swift`
ML 모델 추론 서비스

```swift
// Protocol (Interface)
protocol MLInferenceServiceProtocol {
    func predict(image: UIImage) async throws -> Double
}

// Mock Implementation (개발 단계)
class MockMLInferenceService: MLInferenceServiceProtocol {
    enum SimulationMode {
        case random   // 랜덤 확률
        case highRisk // 항상 높은 위험도 (테스트용)
        case lowRisk  // 항상 낮은 위험도
    }
    
    func predict(image: UIImage) async throws -> Double {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Double.random(in: 0.0...1.0)
    }
}

// Real Implementation (실제 배포용)
// TODO: CoreML 모델 추가 후 구현
class RealMLInferenceService: MLInferenceServiceProtocol {
    private let model: YourMLModel
    
    func predict(image: UIImage) async throws -> Double {
        // 1. 이미지를 CVPixelBuffer로 변환
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            throw MLInferenceError.invalidImage
        }
        
        // 2. ML 모델 예측 실행
        let prediction = try model.prediction(image: pixelBuffer)
        
        // 3. 악성 확률 반환
        return prediction.malignantProbability
    }
}
```

**교체 방법**:
1. `.mlmodel` 파일을 Xcode 프로젝트에 추가
2. Xcode가 자동 생성하는 Swift 클래스 확인
3. `RealMLInferenceService` 구현
4. `SkindiagnosisApp.swift`에서 `MockMLInferenceService` → `RealMLInferenceService` 교체

---

### 3. Presentation Layer (프레젠테이션 계층)

**목적**: UI 표시 및 사용자 인터랙션 처리

#### 📁 ViewModels (MVVM 패턴)

##### `SkindiagnosisViewModel.swift`
메인 화면의 비즈니스 로직 담당

```swift
@MainActor
class SkindiagnosisViewModel: ObservableObject {
    // Published 상태
    @Published var loadingState: LoadingState = .idle
    @Published var analysisResult: SkinAnalysisResult?
    @Published var showWarningPopup: Bool = false
    @Published var selectedImage: UIImage?
    
    // 의존성
    private let analyzeSkinUseCase: AnalyzeSkinUseCase
    
    // 분석 실행
    func analyzeSkin() async {
        loadingState = .loading
        
        do {
            let result = try await analyzeSkinUseCase.execute(image: selectedImage!)
            analysisResult = result
            loadingState = .success
            
            // 80% 이상이면 경고 팝업
            if result.needsSecondaryCheckup {
                showWarningPopup = true
            }
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }
}
```

**설계 이유**:
- `@MainActor`: 모든 UI 업데이트를 메인 스레드에서 보장
- `@Published`: SwiftUI 자동 리렌더링
- UseCase 의존: 비즈니스 로직 분리

---

#### 📁 Views (SwiftUI)

##### `SkindiagnosisView.swift`
메인 화면 (Toss 스타일 미니멀 디자인)

**화면 구성**:
```
┌─────────────────────────────┐
│        Skindiagnosis            │  ← 헤더
│   피부 병변 위험도 검사      │
├─────────────────────────────┤
│                             │
│    [이미지 선택 영역]        │  ← 메인 컨텐츠
│    또는 [분석 결과 카드]     │    (상태에 따라 변경)
│                             │
├─────────────────────────────┤
│   [사진 선택] [촬영]         │  ← 액션 버튼
│      [분석 시작]             │
└─────────────────────────────┘
```

**상태별 UI**:
- **idle**: 이미지 선택 플레이스홀더
- **loading**: 로딩 인디케이터 + 반투명 오버레이
- **success**: 결과 카드 표시
- **error**: 에러 메시지

---

##### `WarningPopup.swift`
80% 이상 악성 확률일 때 표시되는 경고 팝업

```
┌──────────────────────────┐
│     ⚠️ (아이콘)            │
│                          │
│    2차 검진 권장          │
│   악성 확률: 86%          │
│                          │
│ 전문의 상담을 통한        │
│ 정확한 진단을 권장...     │
│                          │
│   [확인했습니다]          │
└──────────────────────────┘
```

**애니메이션**:
- Scale + Opacity transition
- Spring 효과로 부드럽게 등장

---

##### `ResultCard.swift`
분석 결과를 표시하는 카드 컴포넌트

```
┌──────────────────────────┐
│   [분석된 이미지]          │
│                          │
│      분석 결과            │
│       악성 의심           │  ← 색상 구분 (양성: 초록, 악성: 빨강)
│                          │
│      악성 확률            │
│        86%               │
│                          │
│  전문의 상담을 권장...     │
└──────────────────────────┘
```

---

#### 📁 Resources

##### `AppColors.swift`
Toss 스타일 색상 팔레트

```swift
struct AppColors {
    // Primary
    static let primary = Color(hex: "3182F6")        // 메인 블루
    
    // Status
    static let benign = Color(hex: "00C471")         // 양성 (그린)
    static let malignant = Color(hex: "FF6B6B")      // 악성 (레드)
    
    // Text
    static let textPrimary = Color(hex: "191F28")    // 주요 텍스트
    static let textSecondary = Color(hex: "6B7684")  // 보조 텍스트
    
    // Background
    static let background = Color.white              // 배경
    static let cardBackground = Color(hex: "F9FAFB") // 카드 배경
}
```

**색상 선택 이유**:
- **Primary Blue**: 신뢰감, 의료 앱에 적합
- **Benign Green**: 안전, 긍정적 결과
- **Malignant Red**: 주의, 경고

---

## 데이터 흐름

### 사용자 시나리오: 피부 이미지 분석

```
[User Action]
    ↓
1. 사진 선택/촬영
    ↓
[SkindiagnosisView]
    ↓
2. "분석 시작" 버튼 탭
    ↓
[SkindiagnosisViewModel]
    ↓
3. analyzeSkin() 호출
    ↓
[AnalyzeSkinUseCase]
    ↓
4. execute(image:) 실행
    ↓
[MLInferenceService]
    ↓
5. predict(image:) → 확률 반환
    ↓
[AnalyzeSkinUseCase]
    ↓
6. SkinAnalysisResult 생성
    ↓
[SkindiagnosisViewModel]
    ↓
7. @Published 상태 업데이트
    ↓
[SkindiagnosisView]
    ↓
8. UI 자동 리렌더링
    ↓
9. 결과 카드 표시
    ↓
10. (80% 이상이면) 경고 팝업 표시
```

---

## 의존성 주입 (Dependency Injection)

### SkindiagnosisApp.swift

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

**장점**:
1. **테스트 용이성**: Mock 객체로 쉽게 교체
2. **유연성**: 런타임에 다른 구현체 주입 가능
3. **명확한 의존성**: 어떤 객체가 어떤 의존성을 가지는지 명확

---

## 애니메이션 전략

### 스프링 애니메이션 (Spring Animation)

모든 상태 전환에 부드러운 스프링 효과 적용:

```swift
.transition(.scale.combined(with: .opacity))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
```

**적용 위치**:
- 이미지 선택 → 결과 표시
- 결과 카드 등장
- 경고 팝업 등장/사라짐
- 버튼 상태 변경

**파라미터**:
- `response: 0.4`: 빠른 반응 (400ms)
- `dampingFraction: 0.8`: 적당한 바운스 효과

---

## 비즈니스 규칙

### 1. 분류 기준
- **악성 확률 ≥ 50%**: 악성 의심 (Malignant)
- **악성 확률 < 50%**: 양성 (Benign)

### 2. 경고 팝업 표시 기준
- **악성 확률 ≥ 80%**: 2차 검진 권장 팝업 표시

### 3. 확률 표시
- 내부: 0.0 ~ 1.0 (Double)
- 사용자 표시: 0 ~ 100 (Int, %)

---

## 확장 가능성

### 1. 실제 ML 모델 통합

**단계**:
1. `.mlmodel` 파일 추가
2. `RealMLInferenceService` 구현
3. `SkindiagnosisApp.swift`에서 교체

```swift
// Before
private let mlService = MockMLInferenceService()

// After
private let mlService = try! RealMLInferenceService()
```

### 2. 분석 히스토리 기능

**추가 파일**:
- `Domain/Entities/AnalysisHistory.swift`
- `Data/Repositories/HistoryRepository.swift`
- `Presentation/Views/HistoryListView.swift`

### 3. 서버 연동

**추가 계층**:
- `Data/Network/APIService.swift`
- `Data/Repositories/RemoteAnalysisRepository.swift`

---

## 테스트 전략

### Unit Tests

```swift
// AnalyzeSkinUseCaseTests.swift
func testBenignClassification() async throws {
    // Given
    let mockService = MockMLInferenceService(mode: .lowRisk)
    let useCase = AnalyzeSkinUseCase(mlService: mockService)
    
    // When
    let result = try await useCase.execute(image: testImage)
    
    // Then
    XCTAssertEqual(result.classificationType, .benign)
}
```

### UI Tests

```swift
// SkindiagnosisViewModelTests.swift
func testWarningPopupShowsForHighRisk() async {
    // Given
    let mockService = MockMLInferenceService(mode: .highRisk)
    let viewModel = SkindiagnosisViewModel(...)
    
    // When
    await viewModel.analyzeSkin()
    
    // Then
    XCTAssertTrue(viewModel.showWarningPopup)
}
```

---

## 성능 최적화

### 1. 이미지 리사이징
ML 모델 입력 전 이미지를 224x224로 리사이징하여 메모리 절약

### 2. 비동기 처리
`async/await`를 사용하여 메인 스레드 블로킹 방지

### 3. 메모리 관리
분석 완료 후 불필요한 이미지 데이터 해제 고려

---

## 보안 고려사항

### 1. 개인정보 보호
- 이미지는 로컬에서만 처리
- 서버 전송 시 암호화 필요

### 2. 의료 데이터 규정 준수
- HIPAA/GDPR 준수 검토 필요
- 사용자 동의 절차 추가

---

## 참고 자료

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SwiftUI MVVM Best Practices](https://www.swiftbysundell.com)
- [CoreML Documentation](https://developer.apple.com/documentation/coreml)
