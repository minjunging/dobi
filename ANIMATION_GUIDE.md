# 애니메이션 가이드

Skindiagnosis 앱의 프리미엄 애니메이션 시스템을 설명합니다.

---

## 🎯 애니메이션 철학

**목표**: Toss, Apple Health, Apple Wallet과 유사한 차분하고 신뢰감 있는 움직임

### 핵심 원칙

1. **높은 Damping, Bounce 없음**
   - `dampingFraction: 0.88 ~ 0.95`
   - 튕기는 느낌 제거
   - 부드럽고 전문적인 느낌

2. **느리고 의도적인 움직임**
   - `response: 0.4 ~ 0.55초`
   - 사용자가 충분히 읽을 수 있는 속도
   - 급하지 않은 여유로운 전환

3. **연결된 전환**
   - 갑작스러운 변화 없음
   - 모든 상태가 자연스럽게 이어짐
   - 순차적 등장으로 리듬감 제공

4. **미묘한 움직임**
   - Scale: 0.96 ~ 0.98 (과하지 않게)
   - Offset: 8 ~ 20pt (작은 이동)
   - Opacity 전환과 항상 함께 사용

---

## 📐 애니메이션 스타일

### `AnimationStyles.swift` 사용

모든 애니메이션은 중앙화된 스타일을 사용합니다:

```swift
import SwiftUI

// 사용 가능한 애니메이션
Animation.premiumSpring  // 메인 컨텐츠 전환
Animation.quickSpring    // 빠른 UI 변화
Animation.warningSpring  // 경고 팝업
Animation.textAppear     // 텍스트/숫자 등장
```

### 애니메이션 타이밍

```swift
// 사용 가능한 Transition
AnyTransition.resultAppear   // 결과 카드 등장
AnyTransition.textSlideUp    // 텍스트 슬라이드
AnyTransition.warningScale   // 경고 팝업
```

---

## 🎬 화면별 애니메이션

### 1. 결과 카드 (`ResultCard.swift`)

#### 전체 카드 등장
```swift
.transition(.resultAppear)
```
- **효과**: fade in + 아래에서 위로 약간 이동 + 작은 scale
- **타이밍**: premiumSpring (0.55초)
- **Scale**: 0.97 → 1.0
- **Offset**: +20pt → 0

#### 순차적 컨텐츠 등장

**1단계: 분류 레이블 (100ms 지연)**
```swift
withAnimation(.textAppear.delay(0.1)) {
    isLabelVisible = true
}
```
- 텍스트: "양성" 또는 "악성 의심"
- 효과: opacity + 8pt 위로 이동

**2단계: 확률 숫자 (250ms 지연)**
```swift
withAnimation(.textAppear.delay(0.25)) {
    isPercentageVisible = true
}
```
- 큰 숫자: "86%"
- 효과: opacity + 8pt 위로 이동

**3단계: 설명 메시지 (400ms 지연)**
```swift
withAnimation(.textAppear.delay(0.4)) {
    isDescriptionVisible = true
}
```
- 설명: "전문의 상담을 권장드립니다"
- 효과: opacity만 (이동 없음)

**전체 타임라인:**
```
0ms     ┌─ 카드 전체 등장
100ms   ├─ 분류 레이블
250ms   ├─ 확률 숫자
400ms   └─ 설명 메시지
```

---

### 2. 경고 팝업 (`WarningPopup.swift`)

#### Apple 스타일 등장

**배경 (빠른 fade)**
```swift
withAnimation(.easeOut(duration: 0.25)) {
    isBackgroundVisible = true
}
```
- 반투명 검정 배경
- 빠르게 fade in

**카드 (Apple scale)**
```swift
withAnimation(.warningSpring.delay(0.05)) {
    isCardVisible = true
}
```
- Scale: 0.96 → 1.0
- Opacity: 0 → 1
- Damping: 0.92 (overshoot 없음)

**사라질 때**
```swift
// 1. 카드 먼저
withAnimation(.warningSpring) {
    isCardVisible = false
}

// 2. 배경 나중에
withAnimation(.easeIn(duration: 0.2).delay(0.1)) {
    isBackgroundVisible = false
}
```

---

### 3. 메인 화면 (`SkindiagnosisView.swift`)

#### 이미지 선택 시
```swift
.transition(.scale(scale: 0.98).combined(with: .opacity))
.animation(.premiumSpring, value: selectedImage)
```
- 부드러운 등장
- Scale: 0.98 → 1.0
- 이미지 변경 시마다 애니메이션

#### 로딩 오버레이
```swift
.transition(.opacity)
.animation(.easeInOut(duration: 0.3), value: loadingState)
```
- 간단한 fade in/out
- 0.3초로 빠르게 전환

#### 분석 버튼 상태
```swift
.animation(.quickSpring, value: canAnalyze)
```
- 배경 색상: 파란색 ↔ 회색
- 부드러운 전환

---

## 🎨 애니메이션 값 참고

### Spring 파라미터

| 스타일 | Response | Damping | 용도 |
|-------|----------|---------|------|
| `premiumSpring` | 0.55s | 0.88 | 메인 컨텐츠 |
| `quickSpring` | 0.4s | 0.90 | 빠른 UI 변화 |
| `warningSpring` | 0.5s | 0.92 | 경고 팝업 |
| `textAppear` | 0.45s | 0.95 | 텍스트 등장 |

### Scale 값

| 상황 | Scale | 느낌 |
|-----|-------|------|
| 메인 컨텐츠 | 0.97 | 명확한 등장감 |
| 작은 요소 | 0.98 | 미묘한 움직임 |
| 팝업 | 0.96 | Apple 스타일 |

### Offset 값

| 상황 | Offset | 느낌 |
|-----|--------|------|
| 텍스트 | 8pt | 미묘한 슬라이드 |
| 카드 | 20pt | 명확한 등장 |

### 지연 시간

| 단계 | 지연 | 용도 |
|-----|-----|------|
| 첫 번째 | 100ms | 빠른 순차 |
| 두 번째 | 250ms | 기본 간격 |
| 세 번째 | 400ms | 여유로운 등장 |
| 경고 팝업 | 500ms | 결과 확인 후 |

---

## 💻 코드 예시

### 기본 사용법

```swift
import SwiftUI

struct MyView: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack {
            Text("Hello")
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 8)
        }
        .onAppear {
            withAnimation(.premiumSpring) {
                isVisible = true
            }
        }
    }
}
```

### 순차 애니메이션

```swift
struct SequentialView: View {
    @State private var showFirst = false
    @State private var showSecond = false
    @State private var showThird = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("First")
                .opacity(showFirst ? 1 : 0)
                .offset(y: showFirst ? 0 : 8)
            
            Text("Second")
                .opacity(showSecond ? 1 : 0)
                .offset(y: showSecond ? 0 : 8)
            
            Text("Third")
                .opacity(showThird ? 1 : 0)
                .offset(y: showThird ? 0 : 8)
        }
        .onAppear {
            // 순차적으로 등장
            withAnimation(.textAppear.delay(0.1)) {
                showFirst = true
            }
            withAnimation(.textAppear.delay(0.25)) {
                showSecond = true
            }
            withAnimation(.textAppear.delay(0.4)) {
                showThird = true
            }
        }
    }
}
```

### 상태 전환

```swift
struct StateView: View {
    @State private var isSuccess = false
    
    var body: some View {
        VStack {
            if isSuccess {
                SuccessCard()
                    .transition(.resultAppear)
            } else {
                PlaceholderView()
                    .transition(.opacity)
            }
        }
        .animation(.premiumSpring, value: isSuccess)
    }
}
```

---

## 🎯 Do's and Don'ts

### ✅ Do

- **항상 premiumSpring 계열 사용**
  ```swift
  withAnimation(.premiumSpring) { }
  ```

- **Opacity와 다른 효과 함께 사용**
  ```swift
  .opacity(isVisible ? 1 : 0)
  .offset(y: isVisible ? 0 : 8)
  ```

- **순차 애니메이션에 적절한 지연**
  ```swift
  .delay(0.1)  // 100ms
  .delay(0.25) // 250ms
  ```

- **애니메이션과 value 명시**
  ```swift
  .animation(.premiumSpring, value: state)
  ```

### ❌ Don't

- **기본 spring 사용 금지**
  ```swift
  // ❌ 나쁜 예
  withAnimation(.spring()) { }
  
  // ✅ 좋은 예
  withAnimation(.premiumSpring) { }
  ```

- **bounce 있는 애니메이션**
  ```swift
  // ❌ damping 너무 낮음 (튕김)
  .spring(dampingFraction: 0.6)
  
  // ✅ 높은 damping (부드러움)
  .spring(dampingFraction: 0.88)
  ```

- **너무 큰 scale 변화**
  ```swift
  // ❌ 과한 scale
  .scale(0.8)
  
  // ✅ 미묘한 scale
  .scale(0.97)
  ```

- **easeInOut 남용**
  ```swift
  // ❌ 딱딱한 느낌
  .easeInOut(duration: 0.3)
  
  // ✅ 부드러운 spring
  .premiumSpring
  ```

---

## 🔧 커스터마이징

### 새로운 애니메이션 추가

`AnimationStyles.swift`에 추가:

```swift
extension Animation {
    /// 커스텀 애니메이션
    static let myCustom = Animation.spring(
        response: 0.5,        // 속도
        dampingFraction: 0.9, // bounce 정도 (높을수록 부드러움)
        blendDuration: 0.3    // 다른 애니메이션과 블렌딩
    )
}
```

### 새로운 Transition 추가

```swift
extension AnyTransition {
    /// 커스텀 전환
    static let myTransition: AnyTransition = .asymmetric(
        insertion: .scale(scale: 0.95)
            .combined(with: .opacity)
            .combined(with: .offset(y: 10)),
        removal: .opacity
    )
}
```

---

## 📊 성능 최적화

### 애니메이션 성능 팁

1. **필요한 곳에만 애니메이션**
   ```swift
   // ✅ 특정 값만 애니메이션
   .animation(.premiumSpring, value: specificValue)
   
   // ❌ 모든 변화에 애니메이션
   .animation(.premiumSpring)
   ```

2. **복잡한 뷰는 간단한 애니메이션**
   ```swift
   // 복잡한 카드는 opacity만
   ComplexCardView()
       .opacity(isVisible ? 1 : 0)
   ```

3. **transition 대신 opacity + offset**
   ```swift
   // 더 빠름
   .opacity(show ? 1 : 0)
   .offset(y: show ? 0 : 20)
   ```

---

## 🎬 실제 사용 예시

### 결과 화면 전체 플로우

```
1. 사용자가 "분석 시작" 탭
   ↓
2. 로딩 오버레이 fade in (0.3초)
   ↓
3. 1~2초 분석
   ↓
4. 로딩 오버레이 fade out
   ↓
5. 결과 카드 등장 (premiumSpring)
   - Scale: 0.97 → 1.0
   - Offset: +20pt → 0
   - Opacity: 0 → 1
   ↓
6. 100ms 후 분류 레이블 슬라이드 업
   ↓
7. 250ms 후 확률 숫자 슬라이드 업
   ↓
8. 400ms 후 설명 메시지 fade in
   ↓
9. (80% 이상이면) 500ms 후 경고 팝업
   - 배경 fade in (0.25초)
   - 카드 scale + fade (warningSpring)
```

---

## 📖 참고 자료

- [Apple Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [SwiftUI Animation Documentation](https://developer.apple.com/documentation/swiftui/animation)
- Toss 앱 분석
- Apple Health / Wallet 앱 분석

---

**마지막 업데이트**: 2026-02-02
