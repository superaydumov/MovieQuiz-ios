//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Эльдар Айдумов on 18.05.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    /*private let questions: [QuizQuestion] = [
        QuizQuestion (image: "The Godfather",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestion (image: "The Dark Knight",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestion (image: "Kill Bill",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestion (image: "The Avengers",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestion (image: "Deadpool",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestion (image: "The Green Knight",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: true),
        QuizQuestion (image: "Old",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestion (image: "The Ice Age Adventures of Buck Wild",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestion (image: "Tesla",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false),
        QuizQuestion (image: "Vivarium",
                      text: "Рейтинг этого фильма больше чем 6?",
                      correctAnswer: false)]
     */
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion () {
        delegate?.activityIndicator.startAnimating()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies [safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            }
            catch {
                print ("Failed to load image.")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
            let rating = Float (movie.rating) ?? 0
            
            let randomIndex = (0...1).randomElement() ?? 0
            let textIndex = (5...8).randomElement() ?? 0
            var questionsArray: Array = ["Рейтинг этого фильма больше, чем \(textIndex)?",
                                         "Рейтинг этого фильма меньше, чем \(textIndex)?"]
            
            var text = ""
            var correctAnswer: Bool
            
            if randomIndex == 0 {
                text.append(String(questionsArray[0]))
                correctAnswer = rating > Float(textIndex)
            } else {
                text.append(String(questionsArray[1]))
                correctAnswer = rating < Float(textIndex)
            }
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
