# Toss 스타일 디자인 가이드

SkinCheck 앱에 적용된 Toss 스타일 디자인 시스템을 설명합니다.

---

## 🎯 디자인 철학

**"Less is more"** - 최소한의 요소로 최대한의 명확성

### 핵심 원칙

1. **공격적인 여백 사용**
   - 섹션 간 40~48pt 간격
   - 컨텐츠 좌우 32pt 패딩
   - 카드 내부 40pt 패딩
   - 텍스트가 "숨쉴" 수 있는 공간

2. **화면에 최소한의 요소**
   - 한 화면에 하나의 핵심 정보
   - 장식적 요소 완전 제거
   - 필수 정보만 표시

3. **한 번에 하나의 Primary Action**
   - 여러 버튼 동시 표시 금지
   - 명확한 다음 단계 제시
   - 선택의 혼란 제거

4. **텍스트가 숨쉬는 레이아웃**
   - 줄간격 6pt 이상
   - 섹션 간 명확한 구분
   - 빡빡한 그룹핑 피하기

---

## 📐 레이아웃 가이드

### 여백 시스템

```swift
// 섹션 간 여백
Spacer().frame(height: 48)  // 큰 섹션 분리
Spacer().frame(height: 40)  // 중간 섹션 분리
Spacer().frame(height: 32)  // 작은 섹션 분리

// 컨텐츠 패딩
.padding(.horizontal, 32)   // 좌우 여백
.padding(.vertical, 40)     // 상하 여백
```

### 이미지 크기

```swift
// 메인 이미지 (시각적 앵커)
.frame(height: 360)         // 크고 명확하게
.cornerRadius(20)           // 부드러운 모서리
```

### 버튼 규격

```swift
// Primary 버튼
.frame(height: 64)          // 큰 터치 영역
.cornerRadius(32)           // Pill 스타일
.font(.system(size: 18, weight: .semibold))
```

---

## 🎨 색상 시스템

### Primary 색상

```swift
AppColors.primary          // #3182F6 - Toss 블루
  ↓ 사용처
  - Primary 버튼 배경
  - 중요한 아이콘
```

### Status 색상

```swift
AppColors.benign           // #00BA88 - 차분한 그린
AppColors.malignant        // #F04452 - 차분한 레드 (과하지 않게)
  ↓ 특징
  - 채도 낮춰서 눈에 덜 자극적
  - 의료 앱에 적합한 차분한 톤
```

### Neutral 색상

```swift
AppColors.background       // #FFFFFF - 순백
AppColors.cardBackground   // #F7F8FA - 매우 밝은 회색 (부드러운 대비)
AppColors.textPrimary      // #191F28 - 진한 검정
AppColors.textSecondary    // #6B7684 - 중간 회색
AppColors.textTertiary     // #B8BFC8 - 밝은 회색
```

### 색상 사용 원칙

**✅ Do**:
- 배경은 항상 순백
- 텍스트는 3단계 계층만 사용
- 카드 배경으로 미묘한 구분

**❌ Don't**:
- 강한 색상 남발 금지
- 그라데이션 사용 금지
- 장식적 색상 사용 금지

---

## 📝 타이포그래피

### 크기 계층

```swift
// 큰 제목 (화면 제목)
.font(.system(size: 36, weight: .bold))

// 결과 텍스트 (가장 중요)
.font(.system(size: 40, weight: .bold))

// 큰 숫자 (확률 등)
.font(.system(size: 64, weight: .bold))

// 서브타이틀
.font(.system(size: 18, weight: .medium))

// 본문
.font(.system(size: 17))

// 보조 설명
.font(.system(size: 15))
```

### 타이포그래피 원칙

1. **명확한 계층**
   ```
   결과 레이블 (40pt, bold)
     ↓
   확률 숫자 (64pt, bold)
     ↓
   설명 텍스트 (17pt, regular)
   ```

2. **가독성 우선**
   - 최소 15pt 이상
   - 줄간격 6pt 이상
   - 밝은 색 텍스트는 크게

3. **중앙 정렬**
   - 모든 핵심 정보는 중앙
   - 좌우 균형 유지
   - 스캔하기 쉽게

---

## 🖱️ 버튼 디자인

### Primary 버튼

```swift
Button(action: { }) {
    Text("분석 시작")
        .font(.system(size: 18, weight: .semibold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(AppColors.primary)
        .cornerRadius(32)
}
```

**특징**:
- ✅ 크고 친근한 Pill 스타일
- ✅ 충분한 터치 영역 (64pt)
- ✅ 명확한 레이블
- ✅ 한 화면에 하나만

### Secondary 버튼

```swift
Button(action: { }) {
    HStack(spacing: 12) {
        Image(systemName: "photo")
            .font(.system(size: 22))
        
        Text("사진 선택")
            .font(.system(size: 18, weight: .semibold))
    }
    .foregroundColor(AppColors.primary)
    .frame(maxWidth: .infinity)
    .frame(height: 64)
    .background(AppColors.cardBackground)
    .cornerRadius(32)
}
```

**특징**:
- ✅ 부드러운 배경색
- ✅ Primary 색상 텍스트
- ✅ 아이콘 + 텍스트 조합

---

## 📱 화면별 레이아웃

### 1. 초기 화면 (이미지 없음)

```
┌─────────────────────────┐
│                         │ ← 60pt
│      SkinCheck          │ ← 헤더 (중앙)
│    피부 병변 검사        │
│                         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤ ← 40pt
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │    📷 (아이콘)   │   │ ← 360pt 플레이스홀더
│   │ 사진을 선택해주세요 │
│   │                 │   │
│   └─────────────────┘   │
│                         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤ ← 48pt
│                         │
│   [ 사진 선택 ]          │ ← 64pt 버튼
│   [ 촬영하기 ]          │
│                         │
└─────────────────────────┘ ← 40pt
```

### 2. 이미지 선택 후

```
┌─────────────────────────┐
│                         │ ← 60pt
│      SkinCheck          │
│    피부 병변 검사        │
│                         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤ ← 40pt
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │  [선택된 이미지]  │   │ ← 360pt
│   │                 │   │
│   └─────────────────┘   │
│                         │
│ 이 앱은 의료 진단...     │ ← 작은 안내
│                         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤ ← 48pt
│                         │
│    [ 분석 시작 ]         │ ← 단 하나의 버튼
│                         │
└─────────────────────────┘
```

### 3. 결과 화면

```
┌─────────────────────────┐
│                         │ ← 60pt
│      SkinCheck          │
│    피부 병변 검사        │
│                         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤ ← 40pt
│                         │
│   ┌─────────────────┐   │
│   │  [분석 이미지]   │   │ ← 320pt
│   └─────────────────┘   │
│                         │ ← 48pt
│      악성 의심           │ ← 40pt bold
│   전문의 상담 권장       │ ← 17pt
│                         │ ← 40pt
│      악성 확률           │
│        86%              │ ← 64pt bold
│                         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤ ← 48pt
│                         │
│   [ 새로운 검사 ]        │ ← 단 하나의 버튼
│                         │
└─────────────────────────┘
```

---

## ⚠️ 경고 팝업

### 디자인 원칙

1. **화면을 압도하지 않기**
   - 너무 크지 않게
   - 반투명 배경으로 맥락 유지

2. **여백 유지**
   - 팝업 내부에도 충분한 패딩
   - 텍스트가 숨쉬도록

3. **차분한 톤**
   - 큰 아이콘 피하기
   - 강한 색상 최소화
   - 설명은 간결하게

### 레이아웃

```
┌─────────────────────────┐
│ [반투명 배경]            │
│                         │
│  ┌───────────────────┐  │
│  │                   │  │ ← 40pt
│  │    ⚠️ (48pt)      │  │
│  │                   │  │ ← 32pt
│  │   2차 검진 권장    │  │ ← 28pt bold
│  │                   │  │ ← 20pt
│  │      86%          │  │ ← 56pt bold
│  │                   │  │ ← 8pt
│  │ 전문의 상담을...    │  │ ← 17pt
│  │                   │  │ ← 40pt
│  │  [확인했습니다]    │  │ ← 60pt 버튼
│  │                   │  │ ← 32pt
│  └───────────────────┘  │
│                         │
└─────────────────────────┘
```

---

## 🎬 상태 전환

### 플로우

```
초기 화면
  ↓ (사진 선택)
이미지 있음
  ↓ (분석 시작)
로딩
  ↓ (1~2초)
결과 표시
  ↓ (80% 이상이면)
경고 팝업
```

### 각 상태의 Primary Action

| 상태 | Primary Action |
|-----|---------------|
| 초기 | "사진 선택" 또는 "촬영하기" |
| 이미지 선택 후 | "분석 시작" |
| 로딩 중 | 없음 (진행 중) |
| 결과 표시 | "새로운 검사" |
| 경고 팝업 | "확인했습니다" |

---

## ✅ 체크리스트

### 레이아웃

- [ ] 섹션 간 40pt 이상 여백
- [ ] 컨텐츠 좌우 32pt 패딩
- [ ] 이미지 크기 320pt 이상
- [ ] 버튼 높이 64pt
- [ ] 한 화면에 하나의 primary action

### 타이포그래피

- [ ] 결과 텍스트 40pt 이상
- [ ] 숫자 64pt 이상
- [ ] 최소 크기 15pt 이상
- [ ] 줄간격 6pt 이상
- [ ] 중앙 정렬

### 색상

- [ ] 배경 순백
- [ ] 카드 배경 #F7F8FA
- [ ] Primary 버튼 #3182F6
- [ ] 텍스트 3단계 계층만

### 버튼

- [ ] Pill 스타일 (cornerRadius: height/2)
- [ ] 충분한 높이 (64pt)
- [ ] 명확한 레이블
- [ ] 터치 영역 충분

---

## 🚫 피해야 할 것

### ❌ 절대 하지 말 것

1. **빡빡한 레이아웃**
   ```swift
   // ❌ 나쁜 예
   VStack(spacing: 8) { }
   
   // ✅ 좋은 예
   VStack(spacing: 40) { }
   ```

2. **여러 Primary Action**
   ```swift
   // ❌ 나쁜 예 - 선택 혼란
   Button("분석") { }
   Button("저장") { }
   Button("공유") { }
   
   // ✅ 좋은 예 - 명확한 하나
   Button("분석 시작") { }
   ```

3. **작은 텍스트**
   ```swift
   // ❌ 나쁜 예
   .font(.system(size: 12))
   
   // ✅ 좋은 예
   .font(.system(size: 15))
   ```

4. **장식적 요소**
   ```swift
   // ❌ 나쁜 예
   .shadow(radius: 20)
   .border(Color.blue)
   
   // ✅ 좋은 예
   // 배경색으로만 구분
   ```

---

## 📚 참고 자료

- Toss 앱 분석
- Apple Human Interface Guidelines
- Material Design (간격 참고)

---

**최종 목표**: "화면을 보는 순간 무엇을 해야 할지 명확하게"

**마지막 업데이트**: 2026-02-02
