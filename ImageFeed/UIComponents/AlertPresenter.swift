//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 26.03.2025.
//

import UIKit


// MARK: - AlertPresenter
final class SimpleAlertPresenter {
    
    //MARK: - Internal Properties
    
    weak var delegate: UIViewController?
    
    // MARK: - Internal Methods
    
    func presentAlert(_ alert: SimpleAlertModel, cancelable: Bool = false) {
        let ac = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alert.buttonText, style: .default) { _ in
            alert.action()
        }
        ac.addAction(action)
        ac.preferredAction = action
        if cancelable {
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            ac.addAction(cancelAction)
            ac.preferredAction = cancelAction
        }
        delegate?.present(ac, animated: true, completion: nil)
    }
}


// MARK: - AlertModel
struct SimpleAlertModel {
    let title: String
    let message: String
    let buttonText: String
    let action: (() -> ())
    
    init(title: String, message: String, buttonText: String, action: @escaping () -> Void = { }) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.action = action
    }
}
