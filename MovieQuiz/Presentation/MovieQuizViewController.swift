import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var upperLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counterLabelUISetup()
        upperLabelUIsetup()
        previewImageUISetup()
        questionLabelUISetup()
        yesButtonUISetup()
        noButtonUISetup()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    
        alertPresenter = AlertPresenter(delegate: self)
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - UI Setup
    
    private func counterLabelUISetup () {
        counterLabel.text = "0/10"
        counterLabel.textColor = .ypWhite
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }
    
    private func upperLabelUIsetup () {
        upperLabel.text = "Вопрос:"
        upperLabel.textColor = .ypWhite
        upperLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }
    
    private func previewImageUISetup () {
        previewImage.backgroundColor = .ypWhite
        previewImage.layer.masksToBounds = true
        previewImage.layer.cornerRadius = 20
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func questionLabelUISetup () {
        questionLabel.numberOfLines = 2
        questionLabel.textAlignment = .center
        questionLabel.textColor = .ypWhite
        questionLabel.font = UIFont (name: "YSDisplay-Bold", size: 23)
    }
    
    private func yesButtonUISetup () {
        yesButton.layer.cornerRadius = 15
        yesButton.layer.masksToBounds = true
        yesButton.backgroundColor = .ypWhite
        yesButton.setTitle("Да", for: .normal)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.setTitleColor(.ypBlack, for: .normal)
    }
    
    private func noButtonUISetup () {
        noButton.layer.cornerRadius = 15
        noButton.layer.masksToBounds = true
        noButton.backgroundColor = .ypWhite
        noButton.setTitle("Нет", for: .normal)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.setTitleColor(.ypBlack, for: .normal)
    }
    
    // MARK: - Functions
    
    func show (quiz step: QuizStepViewModel) {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAlert () {
        let resultMessage = presenter.makeResultMessage()
        
        let alertModel = AlertModel (title: "Этот раунд окончен!",
                                     message: resultMessage,
                                     buttonText: "Сыграть ещё раз",
                                     completion: { [weak self] in
            guard let self = self else { return }
                self.presenter.restartGame() })
        
        alertPresenter?.show(quiz: alertModel)
    }
    
    func highLightImageBorder (isCorrectAnswer: Bool) {
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if previewImage.layer.borderColor == UIColor.ypGreen.cgColor {
            print ("Дан верный ответ.")
        } else {
            print ("Дан неверный ответ.")
        }
    }
    
    private func showNextQuestionOrResult(isCorrect: Bool) {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        activityIndicator.stopAnimating()
        
        presenter.didCorrectAnswer(isCorrectAnswer: isCorrect)
    }
    
    func showNetworkError (message: String) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        activityIndicator.stopAnimating()
        
        let alertModel = AlertModel (title: "Что-то пошло не так",
                                     message: message,
                                     buttonText: "Попробовать ещё раз",
                                     completion: { [weak self] in
        guard let self = self else { return }
            self.presenter.restartGame() })
        
        alertPresenter?.show(quiz: alertModel)
    }
    
    func enableButtons() {
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
    }
    
    func disableButtons() {
        self.yesButton.isEnabled = false
        self.noButton.isEnabled = false
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
        print ("Нажата кнопка - Да.")
        
        disableButtons()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        
        print ("Нажата кнопка - Нет.")
        
        disableButtons()
    }
}
