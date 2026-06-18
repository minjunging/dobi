//
//  WarningPopup.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI

// MARK: - Warning Popup

/// 80% 이상 악성 확률일 때 표시되는 경고 팝업
/// Apple Health / Wallet 스타일의 프리미엄 모달
///
/// 애니메이션 특징:
/// - 배경: fade in (차분한 등장)
/// - 카드: 0.96 → 1.0 scale + fade in (Apple 스타일)
/// - 높은 damping으로 overshoot 없음
/// - 진지하고 침착한 느낌
struct WarningPopup: View {
    
    // MARK: - Properties
    
    let probabilityPercentage: Int
    let onDismiss: () -> Void
    
    // MARK: - State
    
    @State private var isBackgroundVisible = false
    @State private var isCardVisible = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 반투명 배경 - 부드러운 fade in
            Color.black.opacity(isBackgroundVisible ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // 경고 카드 - 차분하고 여백 충분
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // 경고 아이콘 - 크지만 압도적이지 않게
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                    .symbolRenderingMode(.hierarchical)
                
                Spacer()
                    .frame(height: 32)
                
                VStack(spacing: 20) {
                    // 제목 - 간결하고 명확하게
                    Text("2차 검진 권장")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    // 확률 표시 - 단순하게
                    Text("\(probabilityPercentage)%")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(AppColors.malignant)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // 설명 텍스트 - 여백으로 숨쉬기
                    Text("전문의 상담을 권장드립니다")
                        .font(.system(size: 17))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                    
                    Text("이 앱은 의료 진단 도구가 아닙니다")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // 확인 버튼 - 크고 친근하게
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("확인했습니다")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppColors.primary)
                        .cornerRadius(30)
                }
                
                Spacer()
                    .frame(height: 32)
            }
            .padding(.horizontal, 40)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 24)
            // Apple 스타일 scale 애니메이션 (0.96 → 1.0)
            .scaleEffect(isCardVisible ? 1.0 : 0.96)
            .opacity(isCardVisible ? 1.0 : 0)
        }
        .onAppear {
            startAppearAnimation()
        }
    }
    
    // MARK: - Animation Methods
    
    /// 등장 애니메이션 시작
    /// 배경 먼저, 그 다음 카드
    private func startAppearAnimation() {
        // 1. 배경 fade in (빠르게)
        withAnimation(.easeOut(duration: 0.25)) {
            isBackgroundVisible = true
        }
        
        // 2. 카드 등장 (50ms 지연, 프리미엄 spring)
        withAnimation(.warningSpring.delay(0.05)) {
            isCardVisible = true
        }
    }
    
    /// 사라지는 애니메이션과 함께 dismiss
    private func dismissWithAnimation() {
        withAnimation(.warningSpring) {
            isCardVisible = false
        }
        
        withAnimation(.easeIn(duration: 0.2).delay(0.1)) {
            isBackgroundVisible = false
        }
        
        // 애니메이션 완료 후 실제 dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onDismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    WarningPopup(probabilityPercentage: 86) {
        print("Dismissed")
    }
}
