//
//  GameViewController.swift
//  Quiz
//
//  Created by ILLIA HARKAVY on 12/9/20.
//

import UIKit
import GoogleMobileAds

protocol GameViewControllerDelegate: class {
    
    func gameViewController(_ gameViewController: GameViewController, didFinishWithScore score: Int)
}

class GameViewController: UIViewController {

    weak var delegate: GameViewControllerDelegate?
    var isRevealingAnswer = false
    var questions: [Question]!
    var currentQuestion: Question! {
        didSet {
            let index = questions.firstIndex(of: currentQuestion)!
            navigationItem.title = "Question \(index + 1) of \(questions.count)"
            difficultyLabel.text = currentQuestion.difficulty.name
            categoryLabel.text = currentQuestion.category
            questionLabel.text = String(htmlEncodedString: currentQuestion.question)
            answers = ([currentQuestion.correct_answer] + currentQuestion.incorrect_answers).shuffled()
        }
    }
    var answers: [String]! {
        didSet {
            tableView.reloadData()
        }
    }
    var score: Int! {
        didSet {
            scoreLabel.text = "\(score!)"
        }
    }
    
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        currentQuestion = questions.first
        score = 0
    }
}

extension GameViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "answer", for: indexPath)
        let answer = answers[indexPath.section]
        if isRevealingAnswer {
            if answer == currentQuestion.correct_answer {
                cell.backgroundColor = UIColor.green.withAlphaComponent(0.15)
            } else {
                cell.backgroundColor = UIColor.red.withAlphaComponent(0.15)
            }
        } else {
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        }
        cell.textLabel?.text = String(htmlEncodedString: answer)
        return cell
    }
}

extension GameViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answer = answers[indexPath.section]
        if answer == currentQuestion.correct_answer {
            score += currentQuestion.difficulty.points
        }
        isRevealingAnswer = true
        tableView.reloadData()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [unowned self] _ in
            isRevealingAnswer = false
            let nextIndex = questions.firstIndex(of: currentQuestion)! + 1
            if nextIndex < questions.count {
                currentQuestion = questions[nextIndex]
            } else {
                dismiss(animated: true) {
                    delegate?.gameViewController(self, didFinishWithScore: score)
                }
            }
        }
    }
}

extension String {

    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)

    }
}
