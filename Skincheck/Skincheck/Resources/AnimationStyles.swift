//
//  AnimationStyles.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI

// MARK: - Animation Styles

/// 앱 전체에서 사용하는 프리미엄 애니메이션 스타일
/// Toss, Apple Health, Apple Wallet과 유사한 차분하고 신뢰감 있는 움직임
///
/// 원칙:
/// - 높은 damping으로 bounce 없음
/// - 느리고 의도적인 움직임
/// - 부드러운 전환으로 연결감 제공
extension Animation {
    
    // MARK: - Primary Animations
    
    /// 메인 컨텐츠 전환 애니메이션
    /// 사용처: 결과 카드 등장, 화면 전환
    ///
    /// 특징:
    /// - response: 0.55초 (느리고 의도적)
    /// - damping: 0.88 (bounce 없음)
    /// - 차분하고 프리미엄한 느낌
    static let premiumSpring = Animation.spring(
        response: 0.55,
        dampingFraction: 0.88,
        blendDuration: 0.35
    )
    
    /// 빠른 UI 요소 애니메이션
    /// 사용처: 버튼 상태 변경, 작은 UI 변화
    ///
    /// 특징:
    /// - response: 0.4초
    /// - damping: 0.90 (매우 부드러움)
    static let quickSpring = Animation.spring(
        response: 0.4,
        dampingFraction: 0.90,
        blendDuration: 0.25
    )
    
    /// 경고 팝업 애니메이션
    /// 사용처: 80% 이상 경고 팝업
    ///
    /// 특징:
    /// - response: 0.5초
    /// - damping: 0.92 (overshoot 없음)
    /// - 진지하고 침착한 느낌
    static let warningSpring = Animation.spring(
        response: 0.5,
        dampingFraction: 0.92,
        blendDuration: 0.3
    )
    
    /// 텍스트/숫자 등장 애니메이션
    /// 사용처: 확률 퍼센트, 레이블 텍스트
    ///
    /// 특징:
    /// - response: 0.45초
    /// - damping: 0.95 (거의 linear에 가까움)
    /// - 읽기 편한 부드러운 등장
    static let textAppear = Animation.spring(
        response: 0.45,
        dampingFraction: 0.95,
        blendDuration: 0.2
    )
}

// MARK: - Transition Styles

/// 프리미엄 화면 전환 효과
extension AnyTransition {
    
    /// 결과 카드 등장 전환
    /// fade in + 아래에서 위로 부드럽게 이동
    static let resultAppear: AnyTransition = .asymmetric(
        insertion: .scale(scale: 0.97, anchor: .center)
            .combined(with: .opacity)
            .combined(with: .offset(y: 20)),
        removal: .opacity
    )
    
    /// 텍스트 슬라이드 등장
    /// 작은 위쪽 이동 + fade in
    static let textSlideUp: AnyTransition = .asymmetric(
        insertion: .opacity
            .combined(with: .offset(y: 8)),
        removal: .opacity
    )
    
    /// 경고 팝업 전환
    /// 0.96 → 1.0 scale + fade in (Apple 스타일)
    static let warningScale: AnyTransition = .asymmetric(
        insertion: .scale(scale: 0.96, anchor: .center)
            .combined(with: .opacity),
        removal: .scale(scale: 0.96, anchor: .center)
            .combined(with: .opacity)
    )
}

// MARK: - Animation Timing

/// 애니메이션 타이밍과 지연 값
enum AnimationTiming {
    
    /// 기본 지연 시간 (순차 애니메이션용)
    static let baseDelay: TimeInterval = 0.08
    
    /// 짧은 지연 (빠른 순차 애니메이션)
    static let shortDelay: TimeInterval = 0.05
    
    /// 긴 지연 (강조하고 싶은 요소)
    static let longDelay: TimeInterval = 0.15
    
    /// 경고 팝업 표시 전 지연
    static let warningDelay: TimeInterval = 0.5
}

// MARK: - Premium View Modifier

/// 프리미엄 애니메이션을 위한 View Modifier
extension View {
    
    /// 결과 카드 스타일 등장 애니메이션 적용
    /// - Parameter isVisible: 표시 여부
    func resultCardTransition(isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.97, anchor: .center)
            .offset(y: isVisible ? 0 : 20)
    }
    
    /// 텍스트 슬라이드 업 애니메이션 적용
    /// - Parameters:
    ///   - isVisible: 표시 여부
    ///   - delay: 지연 시간
    func textSlideUpTransition(isVisible: Bool, delay: TimeInterval = 0) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 8)
            .animation(.textAppear.delay(delay), value: isVisible)
    }
}
