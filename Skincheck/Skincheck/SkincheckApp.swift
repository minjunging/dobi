//
//  SkincheckApp.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI

@main
struct SkincheckApp: App {
    
    // MARK: - Dependencies
    
    /// ML 추론 서비스 (Mock)
    /// TODO: 실제 ML 모델로 교체 필요
    private let mlService: MLInferenceServiceProtocol = MockMLInferenceService(mode: .random)
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            // Clean Architecture: 의존성을 상위에서 주입
            let useCase = AnalyzeSkinUseCase(mlService: mlService)
            let viewModel = SkinCheckViewModel(analyzeSkinUseCase: useCase)
            
            SkinCheckView(viewModel: viewModel)
        }
    }
}
