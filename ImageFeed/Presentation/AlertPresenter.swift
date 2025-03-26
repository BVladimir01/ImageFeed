//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 26.03.2025.
//

import UIKit


// MARK: - AlertPresenter
class SimpleAlertPresenter {
    weak var delegate: UIViewController?
    
    func presentAlert(_ alert: SimpleAlertModel) {
        let ac = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        let handler = { (alertAction: UIAlertAction) in
            if let action = alert.action { action() }
        }
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: handler)
        ac.addAction(action)
        ac.preferredAction = action
        delegate?.present(ac, animated: true, completion: nil)
    }
}


// MARK: - AlertModel
struct SimpleAlertModel {
    let title: String
    let message: String
    let buttonText: String
    let action: (() -> ())? = nil
}
