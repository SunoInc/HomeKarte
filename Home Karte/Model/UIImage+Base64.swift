//
//  UIImage+Base64.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/14.
//

import Foundation
import UIKit

extension UIImage {
    /// UIImage を Base64エンコードされた文字列に変換
    func toBase64String() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    /// Base64エンコードされた文字列から UIImage を復元
    static func fromBase64String(_ base64: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: imageData)
    }
}
