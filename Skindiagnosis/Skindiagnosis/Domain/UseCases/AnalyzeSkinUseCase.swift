//
//  AnalyzeSkinUseCase.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import Foundation
import UIKit

// MARK: - Analyze Skin Use Case

/// 피부 이미지 분석 유즈케이스
/// Domain Layer의 비즈니스 로직을 담당
///
/// 책임:
/// - ML 서비스를 통한 이미지 분석
/// - 분석 결과를 SkinAnalysisResult 엔티티로 변환
/// - 비즈니스 규칙 적용 (80% 이상 경고 등)
class AnalyzeSkinUseCase {
    
    // MARK: - Properties
    
    private let mlService: MLInferenceServiceProtocol
    
    // MARK: - Initializer
    
    /// 의존성 주입을 통한 초기화
    /// - Parameter mlService: ML 추론 서비스 (프로토콜로 추상화)
    init(mlService: MLInferenceServiceProtocol) {
        self.mlService = mlService
    }
    
    // MARK: - Execute
    
    /// 피부 이미지 분석 실행
    ///
    /// 프로세스:
    /// 1. ML 서비스를 통해 악성 확률 예측
    /// 2. 확률값을 기반으로 분류 타입 결정
    /// 3. SkinAnalysisResult 엔티티 생성 및 반환
    ///
    /// - Parameter image: 분석할 피부 이미지
    /// - Returns: 분석 결과 (SkinAnalysisResult)
    /// - Throws: ML 추론 과정에서 발생하는 에러
    func execute(image: UIImage) async throws -> SkinAnalysisResult {
        // ML 모델을 통한 악성 확률 예측
        let malignantProbability = try await mlService.predict(image: image)
        
        // 비즈니스 로직: 확률값에 따른 분류 타입 결정
        // 50% 이상이면 악성 의심, 미만이면 양성으로 분류
        let classificationType: ClassificationType = malignantProbability >= 0.5
            ? .malignant
            : .benign
        
        // 분석 결과 엔티티 생성
        let result = SkinAnalysisResult(
            image: image,
            classificationType: classificationType,
            malignantProbability: malignantProbability,
            analyzedAt: Date()
        )
        
        return result
    }
}
