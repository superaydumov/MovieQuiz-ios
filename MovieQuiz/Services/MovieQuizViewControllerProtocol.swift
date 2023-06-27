//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Эльдар Айдумов on 28.06.2023.
//

import Foundation

protocol MovieQuizControllerProtocol: AnyObject {
    func show (quiz step: QuizStepViewModel)
    func showAlert()
    
    func highLightImageBorder (isCorrectAnswer: Bool)
    
    func showNetworkError (message: String)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func enableButtons()
    
}
