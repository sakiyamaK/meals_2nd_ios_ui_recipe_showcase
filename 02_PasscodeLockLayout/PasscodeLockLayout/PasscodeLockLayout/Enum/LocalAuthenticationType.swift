//
//  LocalAuthenticationType.swift
//  PasscodeLockLayout
//
//  Created by 酒井文也 on 2020/08/14.
//  Copyright © 2020 酒井文也. All rights reserved.
//

import Foundation

enum LocalAuthenticationType {

    case authWithFaceID  // FaceIDでのパスコード解除
    case authWithTouchID // TouchIDでのパスコード解除
    case authWithManual  // 手動入力でのパスコード解除

    // MARK: - Function

    func getDescriptionTitle() -> String {
        switch self {
        case .authWithFaceID:
            return "FaceID"
        case .authWithTouchID:
            return "TouchID"
        default:
            return ""
        }
    }

    func getLocalizedReason() -> String {
        switch self {
        case .authWithFaceID, .authWithTouchID:
            return "\(self.getDescriptionTitle())を利用して画面ロックを解除します。"
        default:
            return ""
        }
    }
}
