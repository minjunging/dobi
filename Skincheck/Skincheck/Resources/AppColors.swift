//
//  AppColors.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI

/// 앱 전체에서 사용하는 색상을 관리하는 구조체
/// Toss 스타일의 미니멀하고 부드러운 디자인 색상 팔레트
struct AppColors {
    // MARK: - Primary Colors
    
    /// 메인 액션 버튼 색상 (Toss 블루 - 신뢰감과 친근함)
    static let primary = Color(hex: "3182F6")
    
    /// 보조 액션 버튼 색상 (부드러운 회색)
    static let secondary = Color(hex: "A0A8B5")
    
    // MARK: - Status Colors
    
    /// 양성(Benign) 결과 색상 (차분한 그린)
    static let benign = Color(hex: "00BA88")
    
    /// 악성(Malignant) 결과 색상 (차분한 레드, 과하지 않게)
    static let malignant = Color(hex: "F04452")
    
    // MARK: - Neutral Colors
    
    /// 배경 색상 (순백 - Toss 스타일)
    static let background = Color.white
    
    /// 카드 배경 색상 (매우 밝은 회색, 부드러운 대비)
    static let cardBackground = Color(hex: "F7F8FA")
    
    /// 구분선 색상 (거의 보이지 않을 정도로 부드럽게)
    static let divider = Color(hex: "EBEDF0")
    
    // MARK: - Text Colors
    
    /// 주요 텍스트 색상 (진한 검정, 가독성)
    static let textPrimary = Color(hex: "191F28")
    
    /// 보조 텍스트 색상 (중간 회색)
    static let textSecondary = Color(hex: "6B7684")
    
    /// 비활성 텍스트 색상 (밝은 회색)
    static let textTertiary = Color(hex: "B8BFC8")
}

// MARK: - Color Extension

/// Hex 색상 코드를 SwiftUI Color로 변환하는 확장
/// 예: Color(hex: "3182F6")
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
