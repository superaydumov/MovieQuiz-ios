//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Эльдар Айдумов on 28.06.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizControllerMock: MovieQuizControllerProtocol {
    func showLoadingIndicator() { }
    
    func hideLoadingIndicator() { }
    
    func enableButtons() { }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) { }
    
    func showAlert() { }
    
    func highLightImageBorder(isCorrectAnswer: Bool) { }
    
    func showNetworkError(message: String) { }
}

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizControllerMock()
        let sut = MovieQuizPresenter (viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question text.", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question text.")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
