# 개발 가이드

## 목차
1. [개발 환경 설정](#개발-환경-설정)
2. [코드 스타일 가이드](#코드-스타일-가이드)
3. [컴포넌트 설명](#컴포넌트-설명)
4. [ML 모델 통합](#ml-모델-통합)
5. [디버깅 팁](#디버깅-팁)
6. [배포 체크리스트](#배포-체크리스트)

---

## 개발 환경 설정

### 1. Xcode 프로젝트 설정

#### 필수 권한 추가

Xcode에서 다음 단계를 따라 카메라 및 사진 라이브러리 권한을 추가합니다:

**방법 1: Target Info 설정**

1. Xcode에서 프로젝트 선택
2. **TARGETS** → **Skincheck** 선택
3. **Info** 탭 클릭
4. **Custom iOS Target Properties** 섹션에서 `+` 버튼 클릭
5. 다음 키를 추가:

| Key | Value |
|-----|-------|
| `Privacy - Camera Usage Description` | `피부 병변 촬영을 위해 카메라 접근 권한이 필요합니다.` |
| `Privacy - Photo Library Usage Description` | `피부 병변 이미지를 선택하기 위해 사진 라이브러리 접근 권한이 필요합니다.` |

**방법 2: Info.plist 파일 직접 편집**

프로젝트에 `Info.plist` 파일이 없다면 생성 후 추가:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>피부 병변 촬영을 위해 카메라 접근 권한이 필요합니다.</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>피부 병변 이미지를 선택하기 위해 사진 라이브러리 접근 권한이 필요합니다.</string>
</dict>
</plist>
```

#### 최소 배포 타겟 설정

1. **TARGETS** → **Skincheck**
2. **General** 탭
3. **Minimum Deployments** → **iOS 15.0**

---

## 코드 스타일 가이드

### 파일 명명 규칙

```
✅ 좋은 예:
- SkinCheckView.swift          (PascalCase)
- SkinCheckViewModel.swift
- WarningPopup.swift

❌ 나쁜 예:
- skinCheckView.swift          (camelCase)
- skin_check_view.swift        (snake_case)
```

### 컴포넌트 명명 규칙

```swift
// ✅ 컴포넌트 이름 = 파일명
struct SkinCheckView: View { }

// ❌ 파일명과 불일치
struct MainView: View { }  // 파일명이 SkinCheckView.swift
```

### 주석 작성 규칙

#### MARK 주석 사용

```swift
// MARK: - Section Title

/// 함수 설명 (3줄 이상 설명 문서)
/// - Parameter image: 분석할 이미지
/// - Returns: 분석 결과
func analyzeSkin(image: UIImage) async throws -> SkinAnalysisResult {
    // 구현...
}
```

#### 주석 템플릿

```swift
//
//  FileName.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import Foundation

// MARK: - Type Definition

/// 타입 설명
/// 
/// 상세 설명:
/// - 책임 1
/// - 책임 2
struct TypeName {
    // MARK: - Properties
    
    /// 프로퍼티 설명
    let property: String
    
    // MARK: - Initializer
    
    init(property: String) {
        self.property = property
    }
    
    // MARK: - Methods
    
    /// 메서드 설명
    func method() {
        // 구현
    }
}
```

---

## 컴포넌트 설명

### 1. Domain Layer

#### SkinAnalysisResult (Entity)

**역할**: 피부 분석 결과를 담는 핵심 데이터 모델

```swift
let result = SkinAnalysisResult(
    image: selectedImage,
    classificationType: .malignant,
    malignantProbability: 0.86
)

// 사용 예시
print(result.probabilityPercentage)  // 86
print(result.needsSecondaryCheckup)  // true (≥80%)
print(result.classificationType.displayName)  // "악성 의심"
```

**주요 프로퍼티**:
- `classificationType`: 양성/악성 분류
- `malignantProbability`: 악성 확률 (0.0 ~ 1.0)
- `needsSecondaryCheckup`: 2차 검진 필요 여부 (계산 프로퍼티)

---

#### AnalyzeSkinUseCase (UseCase)

**역할**: 피부 분석 비즈니스 로직 실행

```swift
// 의존성 주입
let mlService = MockMLInferenceService()
let useCase = AnalyzeSkinUseCase(mlService: mlService)

// 실행
let result = try await useCase.execute(image: image)
```

**비즈니스 규칙**:
1. 악성 확률 ≥ 0.5 → 악성 의심
2. 악성 확률 < 0.5 → 양성

---

### 2. Data Layer

#### MLInferenceService

**역할**: ML 모델 추론 실행

**Mock 모드** (현재):
```swift
let service = MockMLInferenceService(mode: .random)   // 랜덤 확률
let service = MockMLInferenceService(mode: .highRisk) // 항상 80%+
let service = MockMLInferenceService(mode: .lowRisk)  // 항상 30% 이하
```

**Real 모드** (ML 모델 추가 후):
```swift
let service = try RealMLInferenceService()

// 내부 동작
// 1. UIImage → CVPixelBuffer 변환
// 2. ML 모델 예측 실행
// 3. 악성 확률 반환 (0.0 ~ 1.0)
```

---

### 3. Presentation Layer

#### SkinCheckViewModel

**역할**: View의 비즈니스 로직 및 상태 관리

**주요 상태**:
```swift
@Published var loadingState: LoadingState     // idle, loading, success, error
@Published var analysisResult: SkinAnalysisResult?
@Published var showWarningPopup: Bool
@Published var selectedImage: UIImage?
```

**주요 메서드**:
```swift
// 분석 실행
await viewModel.analyzeSkin()

// 새로운 분석 시작 (초기화)
viewModel.startNewAnalysis()

// 경고 팝업 닫기
viewModel.dismissWarning()
```

**사용 예시**:
```swift
// View에서 사용
Button("분석 시작") {
    Task {
        await viewModel.analyzeSkin()
    }
}
.disabled(!viewModel.canAnalyze)
```

---

#### SkinCheckView

**역할**: 메인 화면 UI

**상태별 UI**:

| 상태 | 표시 내용 |
|-----|----------|
| `idle` | 이미지 선택 플레이스홀더 + 버튼 |
| `loading` | 로딩 인디케이터 + 반투명 오버레이 |
| `success` | 결과 카드 + "새로운 검사 시작" 버튼 |
| `error` | 에러 메시지 |

**애니메이션**:
```swift
.transition(.scale.combined(with: .opacity))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
```

---

#### ResultCard

**역할**: 분석 결과 표시 카드

**레이아웃**:
```
┌────────────────────┐
│   [이미지]          │
│                    │
│   분석 결과         │
│   악성 의심         │ ← 색상 구분
│                    │
│   악성 확률         │
│     86%            │ ← 큰 숫자
│                    │
│ 전문의 상담을 권장... │
└────────────────────┘
```

**색상 규칙**:
- 양성 → `AppColors.benign` (그린)
- 악성 → `AppColors.malignant` (레드)

---

#### WarningPopup

**역할**: 80% 이상 경고 팝업

**표시 조건**:
```swift
if result.needsSecondaryCheckup {  // ≥80%
    showWarningPopup = true
}
```

**디자인**:
- 반투명 배경 + 카드 모달
- 경고 아이콘 + 텍스트
- "확인했습니다" 버튼

---

## ML 모델 통합

### 1. 모델 준비

#### 모델 스펙

```yaml
입력:
  - 타입: CVPixelBuffer
  - 크기: 224 x 224
  - 형식: RGB

출력:
  - malignantProbability: Double (0.0 ~ 1.0)
  - 또는
  - benignProbability: Double (0.0 ~ 1.0)
  - malignantProbability: Double (0.0 ~ 1.0)
```

#### 모델 파일 추가

1. `.mlmodel` 파일을 Xcode 프로젝트에 드래그앤드롭
2. **Target Membership** 체크: `Skincheck`
3. Xcode가 자동으로 Swift 클래스 생성 확인

예: `SkinCancerClassifier.mlmodel` → `SkinCancerClassifier.swift`

---

### 2. RealMLInferenceService 구현

`Data/Services/MLInferenceService.swift`에 추가:

```swift
import CoreML
import Vision

class RealMLInferenceService: MLInferenceServiceProtocol {
    
    // MARK: - Properties
    
    private let model: VNCoreMLModel
    
    // MARK: - Initializer
    
    init() throws {
        // 1. CoreML 모델 로드
        let mlModel = try SkinCancerClassifier(configuration: MLModelConfiguration())
        
        // 2. Vision 프레임워크 모델로 변환
        self.model = try VNCoreMLModel(for: mlModel.model)
    }
    
    // MARK: - Prediction
    
    func predict(image: UIImage) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            // 1. 이미지 전처리
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: MLInferenceError.invalidImage)
                return
            }
            
            // 2. Vision 요청 생성
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // 3. 결과 파싱
                guard let results = request.results as? [VNClassificationObservation],
                      let malignantResult = results.first(where: { $0.identifier == "malignant" }) else {
                    continuation.resume(throwing: MLInferenceError.predictionFailed)
                    return
                }
                
                // 4. 악성 확률 반환
                let probability = Double(malignantResult.confidence)
                continuation.resume(returning: probability)
            }
            
            // 4. 요청 실행
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
```

---

### 3. 앱에 통합

`SkincheckApp.swift` 수정:

```swift
@main
struct SkincheckApp: App {
    
    // MARK: - Dependencies
    
    private let mlService: MLInferenceServiceProtocol = {
        // 실제 모델 사용
        do {
            return try RealMLInferenceService()
        } catch {
            print("⚠️ ML 모델 로드 실패: \(error)")
            // Fallback to Mock
            return MockMLInferenceService()
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            let useCase = AnalyzeSkinUseCase(mlService: mlService)
            let viewModel = SkinCheckViewModel(analyzeSkinUseCase: useCase)
            
            SkinCheckView(viewModel: viewModel)
        }
    }
}
```

---

### 4. 테스트

#### Unit Test

```swift
import XCTest
@testable import Skincheck

class RealMLInferenceServiceTests: XCTestCase {
    
    var service: RealMLInferenceService!
    
    override func setUp() async throws {
        service = try RealMLInferenceService()
    }
    
    func testPredictReturnsValidProbability() async throws {
        // Given
        let testImage = UIImage(named: "test_benign_sample")!
        
        // When
        let probability = try await service.predict(image: testImage)
        
        // Then
        XCTAssertGreaterThanOrEqual(probability, 0.0)
        XCTAssertLessThanOrEqual(probability, 1.0)
    }
}
```

---

## 디버깅 팁

### 1. 로그 출력

#### ViewModel 상태 추적

```swift
func analyzeSkin() async {
    print("🔍 [DEBUG] 분석 시작: \(Date())")
    loadingState = .loading
    
    do {
        let result = try await analyzeSkinUseCase.execute(image: selectedImage!)
        print("✅ [DEBUG] 분석 성공: \(result.classificationType), 확률: \(result.probabilityPercentage)%")
        
        analysisResult = result
        loadingState = .success
        
    } catch {
        print("❌ [DEBUG] 분석 실패: \(error)")
        loadingState = .error(error.localizedDescription)
    }
}
```

#### ML 서비스 추론 추적

```swift
func predict(image: UIImage) async throws -> Double {
    print("🤖 [ML] 예측 시작")
    print("   - 이미지 크기: \(image.size)")
    
    let probability = try await performPrediction(image)
    
    print("   - 예측 결과: \(probability)")
    return probability
}
```

---

### 2. Preview 활용

#### ViewModel Mock 생성

```swift
#if DEBUG
extension SkinCheckViewModel {
    static var preview: SkinCheckViewModel {
        let mockService = MockMLInferenceService(mode: .highRisk)
        let useCase = AnalyzeSkinUseCase(mlService: mockService)
        return SkinCheckViewModel(analyzeSkinUseCase: useCase)
    }
}
#endif
```

#### Preview에서 사용

```swift
#Preview {
    SkinCheckView(viewModel: .preview)
}

#Preview("성공 상태") {
    let viewModel = SkinCheckViewModel.preview
    viewModel.loadingState = .success
    return SkinCheckView(viewModel: viewModel)
}
```

---

### 3. 시뮬레이터 vs 실제 기기

| 기능 | 시뮬레이터 | 실제 기기 |
|-----|-----------|---------|
| 카메라 촬영 | ❌ 불가능 | ✅ 가능 |
| 포토 라이브러리 | ✅ 가능 (샘플) | ✅ 가능 |
| ML 추론 속도 | 느림 | 빠름 |
| 애니메이션 | 부정확 | 정확 |

**권장**: 최종 테스트는 실제 기기에서!

---

## 배포 체크리스트

### 1. 코드 점검

- [ ] Mock ML Service → Real ML Service 교체
- [ ] 모든 TODO 주석 확인
- [ ] 디버그 로그 제거 또는 조건부 컴파일
- [ ] 에러 핸들링 완성

### 2. 권한 설정

- [ ] 카메라 권한 설명 추가
- [ ] 포토 라이브러리 권한 설명 추가
- [ ] 권한 거부 시 안내 메시지 추가

### 3. 테스트

- [ ] Unit Tests 통과
- [ ] UI Tests 통과
- [ ] 실제 기기 테스트
- [ ] 다양한 이미지 테스트

### 4. UI/UX

- [ ] 모든 화면 애니메이션 확인
- [ ] 다크 모드 지원 (선택)
- [ ] 접근성 (VoiceOver) 테스트
- [ ] 다양한 화면 크기 테스트

### 5. 문서

- [ ] README.md 업데이트
- [ ] 스크린샷 추가
- [ ] 개인정보 처리방침 작성
- [ ] 서비스 이용약관 작성

### 6. App Store 준비

- [ ] 앱 아이콘 (1024x1024)
- [ ] 스크린샷 (모든 디바이스)
- [ ] 앱 설명 작성
- [ ] 키워드 설정
- [ ] 의료 기기 규제 확인

---

## 트러블슈팅

### 문제: 카메라가 작동하지 않음

**원인**: 권한 설정 누락

**해결**:
1. Info.plist에 `NSCameraUsageDescription` 추가
2. 앱 재설치
3. 설정 → Skincheck → 카메라 권한 확인

---

### 문제: ML 모델 로드 실패

**원인**: 모델 파일이 Target에 포함되지 않음

**해결**:
1. `.mlmodel` 파일 선택
2. **Target Membership** 확인
3. `Skincheck` 체크 여부 확인

---

### 문제: 이미지가 표시되지 않음

**원인**: 비동기 로딩 타이밍 이슈

**해결**:
```swift
// ViewModel에서 @MainActor 확인
@MainActor
class SkinCheckViewModel: ObservableObject {
    // ...
}
```

---

### 문제: 애니메이션이 부자연스러움

**원인**: transition과 animation 불일치

**해결**:
```swift
// 명시적으로 value 지정
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: loadingState)
```

---

## 유용한 Xcode 단축키

| 단축키 | 기능 |
|-------|------|
| `Cmd + R` | 빌드 및 실행 |
| `Cmd + .` | 실행 중지 |
| `Cmd + U` | 테스트 실행 |
| `Cmd + B` | 빌드만 |
| `Cmd + Shift + K` | Clean Build |
| `Cmd + Option + P` | Preview 재시작 |

---

## 참고 링크

- [SwiftUI 공식 문서](https://developer.apple.com/documentation/swiftui)
- [CoreML 가이드](https://developer.apple.com/documentation/coreml)
- [Vision 프레임워크](https://developer.apple.com/documentation/vision)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**마지막 업데이트**: 2026-02-02
