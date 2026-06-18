//
//  ResultCard.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI

// MARK: - Result Card

/// 분석 결과를 표시하는 카드 컴포넌트
/// Toss 스타일의 깔끔한 카드 디자인
///
/// 애니메이션 특징:
/// - 카드 전체: fade in + 약간의 scale up (차분한 등장)
/// - 분류 레이블: 지연 후 slide up + fade in
/// - 확률 숫자: 추가 지연 후 slide up + fade in
/// - 설명 메시지: 마지막 fade in
/// - 모든 애니메이션은 높은 damping으로 bounce 없음
struct ResultCard: View {
    
    // MARK: - Properties
    
    let result: SkinAnalysisResult
    
    // MARK: - State
    
    @State private var isLabelVisible = false
    @State private var isPercentageVisible = false
    @State private var isDescriptionVisible = false
    
    // MARK: - Computed Properties
    
    /// 분류 타입에 따른 색상
    private var resultColor: Color {
        switch result.classificationType {
        case .benign:
            return AppColors.benign
        case .malignant:
            return AppColors.malignant
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 분석된 이미지 - 시각적 앵커
            Image(uiImage: result.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 320)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(20)
            
            // 결과 정보 - 공격적인 여백으로 숨쉬기
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 48)
                
                // 분류 결과 - 큰 타이포그래피, 중앙 정렬
                VStack(spacing: 12) {
                    Text(result.classificationType.displayName)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(resultColor)
                    
                    Text(result.classificationType.description)
                        .font(.system(size: 17))
                        .foregroundColor(AppColors.textSecondary)
                }
                .opacity(isLabelVisible ? 1 : 0)
                .offset(y: isLabelVisible ? 0 : 8)
                
                Spacer()
                    .frame(height: 40)
                
                // 확률 표시 - 거대한 숫자로 강조
                VStack(spacing: 8) {
                    Text("악성 확률")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textSecondary)
                        .fontWeight(.medium)
                    
                    Text(result.confidenceText)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                .opacity(isPercentageVisible ? 1 : 0)
                .offset(y: isPercentageVisible ? 0 : 8)
                
                Spacer()
                    .frame(height: 32)
            }
        }
        // 배경 제거 - 여백으로 구분
        .transition(.resultAppear)
        .onAppear {
            startSequentialAnimation()
        }
    }
    
    // MARK: - Animation Sequence
    
    /// 순차적 애니메이션 시작
    /// 각 요소가 자연스럽게 이어지며 등장
    private func startSequentialAnimation() {
        // 1. 분류 레이블 (100ms 지연)
        withAnimation(.textAppear.delay(0.1)) {
            isLabelVisible = true
        }
        
        // 2. 확률 숫자 (250ms 지연)
        withAnimation(.textAppear.delay(0.25)) {
            isPercentageVisible = true
        }
        
        // 3. 설명 메시지 (400ms 지연)
        withAnimation(.textAppear.delay(0.4)) {
            isDescriptionVisible = true
        }
    }
}

// MARK: - Preview

#Preview {
    ResultCard(
        result: SkinAnalysisResult(
            image: UIImage(systemName: "photo")!,
            classificationType: .malignant,
            malignantProbability: 0.86
        )
    )
    .padding()
}
