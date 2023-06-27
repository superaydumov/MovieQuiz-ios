//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Эльдар Айдумов on 21.05.2023.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    func show (quiz model: AlertModel) {
        let alert = UIAlertController (title: model.title, message: model.message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction (title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate?.present (alert, animated: true, completion: nil)
    }
}

