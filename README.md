# SkinCheck - 피부 병변 위험도 검사 앱

[![iOS](https://img.shields.io/badge/iOS-15.0+-black.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg)](ARCHITECTURE.md)

**피부 병변 사진을 분석하여 양성/악성 위험도를 검사하는 iOS 앱**

⚠️ **중요 고지**: 이 앱은 의료 진단 도구가 아닙니다. 2차 검진 필요 여부만 안내하며, 반드시 전문의 상담이 필요합니다.

---

## 📱 주요 기능

### 1. 간편한 이미지 업로드
- 📷 카메라로 직접 촬영
- 🖼️ 포토 라이브러리에서 선택

### 2. AI 기반 분석
- 🤖 ML 모델을 통한 자동 분석
- ⚡️ 빠른 결과 제공 (1~2초)

### 3. 명확한 결과 표시
- ✅ **양성** 또는 ⚠️ **악성 의심** 분류
- 📊 악성 확률 퍼센트 표시
- 🚨 80% 이상 시 2차 검진 권장 팝업

### 4. Toss 스타일 UI/UX
- ✨ 미니멀한 디자인
- 🎨 큰 여백과 명확한 타이포그래피
- 🌊 부드러운 스프링 애니메이션

---

## 🏗️ 아키텍처

**Clean Architecture + MVVM** 패턴을 사용하여 설계되었습니다.

```
📱 Presentation Layer (UI)
    ↓
🎯 Domain Layer (Business Logic)
    ↓
💾 Data Layer (ML Service, API)
```

**자세한 아키텍처 문서**: [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 📂 프로젝트 구조

```
Skincheck/
├── Domain/                          # 비즈니스 로직
│   ├── Entities/                    # 데이터 모델
│   │   └── SkinAnalysisResult.swift
│   └── UseCases/                    # 유즈케이스
│       └── AnalyzeSkinUseCase.swift
│
├── Data/                            # 데이터 처리
│   └── Services/
│       └── MLInferenceService.swift # ML 추론 서비스
│
├── Presentation/                    # UI 레이어
│   ├── Views/
│   │   ├── SkinCheckView.swift      # 메인 화면
│   │   └── Components/              # UI 컴포넌트
│   │       ├── WarningPopup.swift
│   │       ├── ResultCard.swift
│   │       └── CameraView.swift
│   └── ViewModels/
│       └── SkinCheckViewModel.swift
│
├── Resources/
│   └── AppColors.swift              # 색상 팔레트
│
└── SkincheckApp.swift               # 앱 진입점
```

---

## 🚀 시작하기

### 요구사항
- **Xcode** 15.0 이상
- **iOS** 15.0 이상
- **Swift** 5.9 이상

### 설치 방법

1. **프로젝트 클론**
```bash
git clone https://github.com/your-username/SkinCheck.git
cd SkinCheck
```

2. **Xcode에서 열기**
```bash
open Skincheck/Skincheck.xcodeproj
```

3. **권한 설정 (중요!)**

Xcode에서 프로젝트 설정을 열고 다음 권한을 추가해야 합니다:

**방법 1: Info.plist 직접 편집**

프로젝트에 `Info.plist` 파일을 추가하고 다음 내용을 입력:

```xml
<key>NSCameraUsageDescription</key>
<string>피부 병변 촬영을 위해 카메라 접근 권한이 필요합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>피부 병변 이미지를 선택하기 위해 사진 라이브러리 접근 권한이 필요합니다.</string>
```

**방법 2: Target Settings에서 추가**

1. Xcode에서 프로젝트 선택
2. **Targets** → **Skincheck** 선택
3. **Info** 탭 선택
4. **Custom iOS Target Properties** 섹션에서 `+` 버튼 클릭
5. 다음 키 추가:
   - `Privacy - Camera Usage Description`
   - `Privacy - Photo Library Usage Description`

4. **빌드 및 실행**
- 시뮬레이터: `Cmd + R`
- 실제 기기: 개발자 계정 필요

---

## 🧪 테스트 모드

현재는 **Mock ML Service**를 사용하여 랜덤 확률을 반환합니다.

### 시뮬레이션 모드 변경

`SkincheckApp.swift`에서 모드 변경 가능:

```swift
// 랜덤 확률 (기본값)
private let mlService = MockMLInferenceService(mode: .random)

// 항상 높은 위험도 (경고 팝업 테스트용)
private let mlService = MockMLInferenceService(mode: .highRisk)

// 항상 낮은 위험도
private let mlService = MockMLInferenceService(mode: .lowRisk)
```

---

## 🤖 실제 ML 모델 통합 방법

### 1. ML 모델 준비

CoreML 모델 파일(`.mlmodel`)을 준비합니다.

**모델 요구사항**:
- **입력**: 피부 이미지 (`CVPixelBuffer`, 224x224)
- **출력**: 악성 확률 (`Double`, 0.0 ~ 1.0)

### 2. 모델 파일 추가

1. `.mlmodel` 파일을 Xcode 프로젝트에 드래그앤드롭
2. **Target Membership** 체크
3. Xcode가 자동으로 Swift 클래스 생성

### 3. RealMLInferenceService 구현

`MLInferenceService.swift`에 다음 클래스 추가:

```swift
class RealMLInferenceService: MLInferenceServiceProtocol {
    private let model: YourMLModel
    
    init() throws {
        self.model = try YourMLModel(configuration: MLModelConfiguration())
    }
    
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

### 4. 앱에서 교체

`SkincheckApp.swift` 수정:

```swift
// Before
private let mlService: MLInferenceServiceProtocol = MockMLInferenceService()

// After
private let mlService: MLInferenceServiceProtocol = try! RealMLInferenceService()
```

---

## 🎨 디자인 시스템

### 색상 팔레트 (Toss 스타일)

```swift
AppColors.primary         // #3182F6 - 메인 블루
AppColors.benign          // #00C471 - 양성 (그린)
AppColors.malignant       // #FF6B6B - 악성 (레드)
AppColors.textPrimary     // #191F28 - 주요 텍스트
AppColors.textSecondary   // #6B7684 - 보조 텍스트
AppColors.cardBackground  // #F9FAFB - 카드 배경
```

### 타이포그래피

```swift
.font(.system(size: 34, weight: .bold))    // 제목
.font(.system(size: 17, weight: .semibold)) // 버튼
.font(.system(size: 15))                    // 본문
```

### 버튼 스타일

```swift
// 큰 둥근 버튼 (Pill 스타일)
.frame(height: 56)
.cornerRadius(28)
```

---

## 📊 사용 흐름

```
1. 앱 실행
    ↓
2. "사진 선택" 또는 "촬영" 버튼 탭
    ↓
3. 이미지 선택/촬영
    ↓
4. "분석 시작" 버튼 탭
    ↓
5. 로딩 인디케이터 표시 (1~2초)
    ↓
6. 결과 카드 표시
   - 분류: 양성 / 악성 의심
   - 확률: 86%
    ↓
7. (80% 이상이면) 경고 팝업 표시
   "2차 검진 권장"
```

---

## 🔒 개인정보 보호

### 현재 구현
- ✅ **로컬 처리**: 모든 이미지는 기기 내에서만 처리
- ✅ **서버 전송 없음**: 네트워크 통신 없음

### 향후 추가 필요 (서버 연동 시)
- 🔐 **암호화**: 이미지 전송 시 SSL/TLS
- 📝 **사용자 동의**: 데이터 수집 동의 절차
- 🗑️ **데이터 삭제**: 분석 후 서버에서 즉시 삭제

---

## 🧪 테스트

### Unit Tests

```bash
# 모든 테스트 실행
Cmd + U
```

**테스트 커버리지 목표**:
- Domain Layer: 100%
- ViewModels: 80%+
- Services: 80%+

### UI Tests

시뮬레이터 또는 실제 기기에서 수동 테스트:

1. ✅ 사진 선택 → 분석 → 결과 표시
2. ✅ 카메라 촬영 → 분석 → 결과 표시
3. ✅ 80% 이상 결과 → 경고 팝업 표시
4. ✅ 새로운 분석 시작 → 상태 초기화

---

## 🛠️ 기술 스택

| 카테고리 | 기술 |
|---------|------|
| **언어** | Swift 5.9 |
| **UI** | SwiftUI |
| **아키텍처** | Clean Architecture + MVVM |
| **ML** | CoreML (예정) |
| **비동기** | async/await |
| **의존성 관리** | 없음 (순수 Swift) |

---

## 📈 로드맵

### v1.0 (현재 - MVP)
- [x] 기본 UI/UX
- [x] Mock ML 서비스
- [x] 사진 선택/촬영
- [x] 결과 표시
- [x] 경고 팝업

### v1.1 (다음)
- [ ] 실제 CoreML 모델 통합
- [ ] 분석 히스토리 기능
- [ ] 다국어 지원 (영어)

### v2.0 (향후)
- [ ] 서버 연동
- [ ] 클라우드 ML 모델
- [ ] 전문의 상담 연결
- [ ] Apple Health 연동

---

## 🤝 기여

프로젝트 개선에 기여하고 싶으시다면:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 라이선스

이 프로젝트는 개인 학습 및 연구 목적으로 제작되었습니다.

**의료 기기 규제**: 실제 배포 시 각 국가의 의료 기기 규제를 준수해야 합니다.
- 한국: 식품의약품안전처 승인 필요
- 미국: FDA 510(k) 승인 필요
- 유럽: CE 마크 필요

---

## 📞 문의

프로젝트 관련 문의:
- Email: your-email@example.com
- Issues: [GitHub Issues](https://github.com/your-username/SkinCheck/issues)

---

## ⚠️ 면책 조항

**이 앱은 의료 진단 도구가 아닙니다.**

- 본 앱의 분석 결과는 참고용일 뿐이며 의학적 진단을 대체할 수 없습니다.
- 피부 이상이 의심되는 경우 반드시 전문의와 상담하시기 바랍니다.
- 본 앱의 사용으로 인한 어떠한 결과에 대해서도 개발자는 책임을 지지 않습니다.

---

Made with ❤️ by 신종원