//
//  MLInferenceService.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import Foundation
import UIKit
import CoreML

// MARK: - ML Inference Error

/// ML 추론 과정에서 발생할 수 있는 에러
enum MLInferenceError: LocalizedError {
    case modelNotFound
    case invalidImage
    case predictionFailed
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "ML 모델을 찾을 수 없습니다"
        case .invalidImage:
            return "유효하지 않은 이미지입니다"
        case .predictionFailed:
            return "분석에 실패했습니다"
        }
    }
}

// MARK: - ML Inference Service Protocol

/// ML 추론 서비스 프로토콜
/// 실제 구현체와 Mock을 교체 가능하도록 설계
protocol MLInferenceServiceProtocol {
    func predict(image: UIImage) async throws -> Double
}

// MARK: - Mock ML Inference Service

/// 실제 ML 모델이 준비되기 전까지 사용할 Mock 서비스
/// TODO: 실제 CoreML 모델로 교체 필요
///
/// 교체 방법:
/// 1. .mlmodel 파일을 Xcode 프로젝트에 추가
/// 2. Xcode가 자동으로 생성하는 Swift 클래스 활용
/// 3. MockMLInferenceService를 RealMLInferenceService로 교체
///
/// 예시 코드:
/// ```swift
/// class RealMLInferenceService: MLInferenceServiceProtocol {
///     private let model: YourMLModel
///
///     init() throws {
///         self.model = try YourMLModel(configuration: MLModelConfiguration())
///     }
///
///     func predict(image: UIImage) async throws -> Double {
///         guard let pixelBuffer = image.toCVPixelBuffer() else {
///             throw MLInferenceError.invalidImage
///         }
///
///         let prediction = try model.prediction(image: pixelBuffer)
///         return prediction.malignantProbability
///     }
/// }
/// ```
class MockMLInferenceService: MLInferenceServiceProtocol {
    
    // MARK: - Properties
    
    /// 테스트용 시뮬레이션 모드
    /// - random: 랜덤 확률 반환
    /// - highRisk: 항상 높은 위험도 반환 (경고 팝업 테스트용)
    /// - lowRisk: 항상 낮은 위험도 반환
    enum SimulationMode {
        case random
        case highRisk
        case lowRisk
    }
    
    private let mode: SimulationMode
    
    // MARK: - Initializer
    
    init(mode: SimulationMode = .random) {
        self.mode = mode
    }
    
    // MARK: - ML Inference
    
    /// Mock 예측 함수
    /// 실제 ML 모델 대신 시뮬레이션 값을 반환
    func predict(image: UIImage) async throws -> Double {
        // 네트워크 지연 시뮬레이션 (1~2초)
        try await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000...2_000_000_000))
        
        // 이미지 유효성 검증
        guard image.size.width > 0 && image.size.height > 0 else {
            throw MLInferenceError.invalidImage
        }
        
        // 시뮬레이션 모드에 따라 다른 확률 반환
        switch mode {
        case .random:
            // 0.0 ~ 1.0 사이의 랜덤 값
            return Double.random(in: 0.0...1.0)
            
        case .highRisk:
            // 80% 이상의 높은 위험도 (경고 팝업 테스트용)
            return Double.random(in: 0.8...0.95)
            
        case .lowRisk:
            // 30% 이하의 낮은 위험도
            return Double.random(in: 0.05...0.30)
        }
    }
}

// MARK: - UIImage Extension

/// UIImage를 CVPixelBuffer로 변환하는 확장
/// 실제 CoreML 모델 사용 시 필요
extension UIImage {
    /// UIImage를 CVPixelBuffer로 변환
    /// CoreML 모델의 입력 형식으로 사용
    ///
    /// - Parameters:
    ///   - width: 출력 이미지 너비 (기본값: 224)
    ///   - height: 출력 이미지 높이 (기본값: 224)
    /// - Returns: 변환된 CVPixelBuffer 또는 nil
    func toCVPixelBuffer(width: Int = 224, height: Int = 224) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        return pixelBuffer
    }
}
