//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Эльдар Айдумов on 25.06.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount = 10
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    private weak var viewController: MovieQuizControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    
    var currentQuestion: QuizQuestion?
    
    init (viewController: MovieQuizControllerProtocol?) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
   
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        
        guard let question = question else {
            return }
        
        currentQuestion = question
        let viewModel = convert (model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer () {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData (with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Functions
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert (model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                             question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func didAnswer (isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func proceedToNextQuestionOrResult () {
        viewController?.showLoadingIndicator()
        if self.isLastQuestion() {
            viewController?.showAlert()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didCorrectAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
    }
    
    func makeResultMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else { return "Something went wrong!"}
        
        let resultMessage =
    """
    Ваш результат: \(correctAnswers)\\\(questionsAmount)
    Количество сыгранных квизов: \(statisticService.gamesCount)
    Рекорд: \(bestGame.correct)\\\(bestGame.total) \(bestGame.date.dateTimeString)
    Средняя точность: \(String (format: "%.2f", statisticService.totalAccuracy))%
    """
        return resultMessage
    }
    
    func proceedWithAnswer (isCorrect: Bool) {
        didCorrectAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highLightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in guard let self = self else { return }
            self.proceedToNextQuestionOrResult()
            viewController?.enableButtons()
        }
    }
}
