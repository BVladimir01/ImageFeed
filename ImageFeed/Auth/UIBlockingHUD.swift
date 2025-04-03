//
//  UIBlockingHUD.swift
//  ImageFeed
//
//  Created by Vladimir on 25.03.2025.
//

import ProgressHUD
import UIKit


final class UIBlockingHUD {
    
    // MARK: - Private Properties
    
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("UIBlockingHud.window: Failed to get windowScene or its window when showing HUD")
            return nil
        }
        return window
    }
    
    // MARK: Initializers
    
    private init () { }
    
    // MARK: - Internal Methods
    
    static func show() {
        ProgressHUD.animate()
        window?.isUserInteractionEnabled = false
    }
    
    static func dismiss() {
        ProgressHUD.dismiss()
        window?.isUserInteractionEnabled = true
    }
    
}
