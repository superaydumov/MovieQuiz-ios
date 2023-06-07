//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Эльдар Айдумов on 20.05.2023.
//

import Foundation
import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion (question: QuizQuestion?)
    
    func didLoadDataFromServer ()
    func didFailToLoadData (with error: Error)
    
    var activityIndicator: UIActivityIndicatorView! { get }
}
