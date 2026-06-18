//
//  SkinCheckView.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI
import PhotosUI

// MARK: - Skin Check View

/// 피부 검사 메인 화면
/// Toss, Apple Health 스타일의 프리미엄 UI
///
/// 화면 구성:
/// 1. 상단: 제목
/// 2. 중앙: 이미지 선택 영역 또는 분석 결과
/// 3. 하단: 액션 버튼들
///
/// 애니메이션 원칙:
/// - 모든 전환은 높은 damping의 spring 사용
/// - 부드럽고 의도적인 움직임
/// - 상태 변화가 자연스럽게 연결됨
/// - bounce 없는 차분한 느낌
struct SkinCheckView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: SkinCheckViewModel
    
    // MARK: - Initializer
    
    init(viewModel: SkinCheckViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 배경
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // 헤더 (Toss 스타일 - 큰 여백)
                    headerView
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // 메인 컨텐츠 (시각적 앵커)
                    mainContentView
                    
                    Spacer()
                        .frame(height: 48)
                    
                    // 액션 버튼 (한 번에 하나만)
                    actionButtonsView
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
            
            // 경고 팝업 (80% 이상일 때)
            // 프리미엄 등장 애니메이션 적용
            if viewModel.showWarningPopup, let result = viewModel.analysisResult {
                WarningPopup(
                    probabilityPercentage: result.probabilityPercentage,
                    onDismiss: {
                        viewModel.dismissWarning()
                    }
                )
                .zIndex(1)
            }
        }
        .sheet(isPresented: $viewModel.showCamera) {
            CameraView { image in
                viewModel.setImageFromCamera(image)
            }
        }
    }
    
    // MARK: - Header View
    
    /// 상단 헤더 영역 (Toss 스타일 - 미니멀)
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("SkinCheck")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("피부 병변 검사")
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Main Content View
    
    /// 메인 컨텐츠 영역 (상태에 따라 다른 뷰 표시)
    @ViewBuilder
    private var mainContentView: some View {
        switch viewModel.loadingState {
        case .idle:
            idleStateView
            
        case .loading:
            loadingStateView
            
        case .success:
            if let result = viewModel.analysisResult {
                ResultCard(result: result)
                    .transition(.resultAppear)
                    .animation(.premiumSpring, value: viewModel.loadingState)
            }
            
        case .error(let message):
            errorStateView(message: message)
        }
    }
    
    // MARK: - Idle State View
    
    /// 대기 상태 뷰 (Toss 스타일 - 미니멀, 큰 이미지)
    private var idleStateView: some View {
        VStack(spacing: 0) {
            // 선택된 이미지가 있으면 표시 (시각적 앵커)
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 360)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(20)
                    .transition(.scale(scale: 0.98).combined(with: .opacity))
                    .animation(.premiumSpring, value: viewModel.selectedImage)
                
                Spacer()
                    .frame(height: 32)
                
                // 간단한 안내
                Text("이 앱은 의료 진단 도구가 아닙니다")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
                
            } else {
                // 플레이스홀더 - 극도로 단순하게
                VStack(spacing: 0) {
                    Spacer()
                    
                    Image(systemName: "photo")
                        .font(.system(size: 72))
                        .foregroundColor(AppColors.textTertiary)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    Text("사진을 선택해주세요")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSecondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .frame(height: 360)
                .frame(maxWidth: .infinity)
                .background(AppColors.cardBackground)
                .cornerRadius(20)
            }
        }
    }
    
    // MARK: - Loading State View
    
    /// 로딩 상태 뷰 (Toss 스타일 - 깔끔)
    private var loadingStateView: some View {
        VStack(spacing: 0) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 360)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(20)
                    .overlay(
                        // 로딩 오버레이 (미니멀)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                    
                                    Text("분석 중")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            )
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.loadingState)
                    )
            }
        }
    }
    
    // MARK: - Error State View
    
    /// 에러 상태 뷰 (Toss 스타일 - 여백 충분)
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            Spacer()
                .frame(height: 24)
            
            Text("오류가 발생했습니다")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
                .frame(height: 12)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            Spacer()
        }
        .frame(height: 360)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .transition(.scale(scale: 0.97).combined(with: .opacity))
        .animation(.premiumSpring, value: viewModel.loadingState)
    }
    
    // MARK: - Action Buttons View
    
    /// 액션 버튼 영역 (Toss 스타일 - 한 번에 하나만)
    @ViewBuilder
    private var actionButtonsView: some View {
        if viewModel.hasResult {
            // 결과 화면: 단 하나의 primary action
            Button(action: {
                viewModel.startNewAnalysis()
            }) {
                Text("새로운 검사")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.primary)
                    .cornerRadius(32)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            .animation(.premiumSpring, value: viewModel.hasResult)
            
        } else if viewModel.selectedImage == nil {
            // 이미지 없을 때: 선택 버튼만
            VStack(spacing: 16) {
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
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
                
                Button(action: {
                    viewModel.showCamera = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera")
                            .font(.system(size: 22))
                        
                        Text("촬영하기")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.cardBackground)
                    .cornerRadius(32)
                }
            }
            
        } else {
            // 이미지 있을 때: 단 하나의 primary action
            Button(action: {
                Task {
                    await viewModel.analyzeSkin()
                }
            }) {
                Text("분석 시작")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(
                        viewModel.canAnalyze
                            ? AppColors.primary
                            : AppColors.textTertiary
                    )
                    .cornerRadius(32)
                    .animation(.quickSpring, value: viewModel.canAnalyze)
            }
            .disabled(!viewModel.canAnalyze)
        }
    }
}

// MARK: - Preview

#Preview {
    // Mock 서비스로 프리뷰 생성
    let mockService = MockMLInferenceService(mode: .random)
    let useCase = AnalyzeSkinUseCase(mlService: mockService)
    let viewModel = SkinCheckViewModel(analyzeSkinUseCase: useCase)
    
    return SkinCheckView(viewModel: viewModel)
}
