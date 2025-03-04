//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: UIViewController, didAuthenticateWith code: String)
    func webViewViewControllerDidCancel(_ vc: UIViewController)
}
