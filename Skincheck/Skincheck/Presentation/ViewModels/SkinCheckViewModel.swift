//
//  SkinCheckViewModel.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import Foundation
import SwiftUI
import PhotosUI
import UIKit
import Combine

// MARK: - Loading State

/// 로딩 상태를 나타내는 열거형
/// Equatable을 준수하여 SwiftUI의 상태 비교 및 애니메이션 트리거를 정확하게 처리
enum LoadingState: Equatable {
    case idle           // 대기 중
    case loading        // 분석 중
    case success        // 분석 완료
    case error(String)  // 에러 발생
    
    // MARK: - Equatable
    
    /// Equatable 준수를 위한 비교 연산자
    /// error case의 associated value를 비교하여 정확한 상태 변화 감지
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.success, .success):
            return true
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - Skin Check View Model

/// 피부 검사 화면의 ViewModel
/// MVVM 패턴의 핵심 - View와 비즈니스 로직 분리
///
/// 책임:
/// - 사용자 입력 처리 (사진 선택, 분석 요청)
/// - 유즈케이스 실행 및 결과 관리
/// - View에 표시할 상태 관리
/// - 애니메이션 트리거 제어
@MainActor
class SkinCheckViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 현재 로딩 상태
    @Published var loadingState: LoadingState = .idle
    
    /// 분석 결과
    @Published var analysisResult: SkinAnalysisResult?
    
    /// 경고 팝업 표시 여부
    @Published var showWarningPopup: Bool = false
    
    /// 선택된 이미지
    @Published var selectedImage: UIImage?
    
    /// 포토 피커 아이템
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            Task {
                await loadSelectedImage()
            }
        }
    }
    
    /// 카메라 표시 여부
    @Published var showCamera: Bool = false
    
    // MARK: - Dependencies
    
    private let analyzeSkinUseCase: AnalyzeSkinUseCase
    
    // MARK: - Computed Properties
    
    /// 분석 중인지 여부
    var isAnalyzing: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }
    
    /// 분석 완료 여부
    var hasResult: Bool {
        analysisResult != nil
    }
    
    /// 분석 버튼 활성화 여부
    var canAnalyze: Bool {
        selectedImage != nil && !isAnalyzing
    }
    
    // MARK: - Initializer
    
    /// 의존성 주입을 통한 초기화
    /// - Parameter analyzeSkinUseCase: 피부 분석 유즈케이스
    init(analyzeSkinUseCase: AnalyzeSkinUseCase) {
        self.analyzeSkinUseCase = analyzeSkinUseCase
    }
    
    // MARK: - Image Selection
    
    /// 포토 라이브러리에서 선택한 이미지 로드
    private func loadSelectedImage() async {
        guard let item = selectedPhotoItem else { return }
        
        do {
            // PhotosPickerItem에서 Data로 변환
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                loadingState = .error("이미지를 불러올 수 없습니다")
                return
            }
            
            selectedImage = image
            
            // 이미지 선택 시 이전 결과 초기화
            analysisResult = nil
            showWarningPopup = false
            loadingState = .idle
            
        } catch {
            loadingState = .error("이미지 로드 실패: \(error.localizedDescription)")
        }
    }
    
    /// 카메라로 촬영한 이미지 설정
    /// - Parameter image: 촬영된 이미지
    func setImageFromCamera(_ image: UIImage) {
        selectedImage = image
        analysisResult = nil
        showWarningPopup = false
        loadingState = .idle
    }
    
    // MARK: - Analysis
    
    /// 피부 이미지 분석 실행
    ///
    /// 프로세스:
    /// 1. 로딩 상태로 전환
    /// 2. 유즈케이스 실행
    /// 3. 결과 저장 및 성공 상태로 전환
    /// 4. 80% 이상이면 경고 팝업 표시
    func analyzeSkin() async {
        guard let image = selectedImage else {
            loadingState = .error("이미지를 먼저 선택해주세요")
            return
        }
        
        // 로딩 상태로 전환
        loadingState = .loading
        
        do {
            // 유즈케이스 실행
            let result = try await analyzeSkinUseCase.execute(image: image)
            
            // 결과 저장
            analysisResult = result
            loadingState = .success
            
            // 80% 이상이면 경고 팝업 표시 (애니메이션 지연)
            if result.needsSecondaryCheckup {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초 지연
                showWarningPopup = true
            }
            
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    
    /// 새로운 분석 시작 (초기화)
    /// 프리미엄 spring 애니메이션으로 부드럽게 전환
    func startNewAnalysis() {
        withAnimation(.premiumSpring) {
            selectedImage = nil
            analysisResult = nil
            showWarningPopup = false
            loadingState = .idle
        }
    }
    
    /// 경고 팝업 닫기
    /// 빠른 spring으로 자연스럽게 사라짐
    func dismissWarning() {
        showWarningPopup = false
    }
}
