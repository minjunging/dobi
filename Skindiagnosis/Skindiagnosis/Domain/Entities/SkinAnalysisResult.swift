//
//  SkinAnalysisResult.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import Foundation
import UIKit

// MARK: - Classification Type

/// 피부 병변 분류 타입
/// - benign: 양성 (위험하지 않음)
/// - malignant: 악성 (의심됨)
enum ClassificationType: String {
    case benign = "Benign"
    case malignant = "Malignant"
    
    /// 한글 표시명
    var displayName: String {
        switch self {
        case .benign:
            return "양성"
        case .malignant:
            return "악성 의심"
        }
    }
    
    /// 결과 설명 메시지
    var description: String {
        switch self {
        case .benign:
            return "걱정하지 않으셔도 괜찮아요"
        case .malignant:
            return "전문의 상담을 권장드립니다"
        }
    }
}

// MARK: - Skin Analysis Result

/// 피부 분석 결과를 담는 엔티티
/// Domain Layer의 핵심 데이터 모델
struct SkinAnalysisResult {
    /// 분석에 사용된 원본 이미지
    let image: UIImage
    
    /// 분류 타입 (양성/악성)
    let classificationType: ClassificationType
    
    /// 악성 확률 (0.0 ~ 1.0)
    let malignantProbability: Double
    
    /// 분석 완료 시각
    let analyzedAt: Date
    
    // MARK: - Computed Properties
    
    /// 퍼센트로 표시되는 확률 (0 ~ 100)
    var probabilityPercentage: Int {
        return Int(malignantProbability * 100)
    }
    
    /// 2차 검진이 필요한지 여부 (80% 이상이면 true)
    var needsSecondaryCheckup: Bool {
        return malignantProbability >= 0.8
    }
    
    /// 신뢰도 텍스트
    var confidenceText: String {
        return "\(probabilityPercentage)%"
    }
    
    // MARK: - Initializer
    
    init(
        image: UIImage,
        classificationType: ClassificationType,
        malignantProbability: Double,
        analyzedAt: Date = Date()
    ) {
        self.image = image
        self.classificationType = classificationType
        self.malignantProbability = max(0.0, min(1.0, malignantProbability)) // 0.0 ~ 1.0 범위로 제한
        self.analyzedAt = analyzedAt
    }
}
