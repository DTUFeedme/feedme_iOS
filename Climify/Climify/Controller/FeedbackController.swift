//
//  FeedbackController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 26/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedbackController: UIViewController {
    
    
    @IBOutlet var backButton: UIBarButtonItem!
    var feedback = Feedback.init()
    let feedbackReceivedSegue = "feedbackreceived"
    
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var question: UILabel!
    
    let networkService = NetworkService()
    var currentQuestionNo = 1
    var questions: [String] = []
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        if currentQuestionNo > 1 {
        currentQuestionNo -= 1
        updateUI()
        backgroundView.transform = CGAffineTransform(translationX: -backgroundView.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        }
    }
    
    @IBAction func temperatureFeedback(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            feedback.temperature = .low
        case 1:
            feedback.temperature = .fine
        case 2:
            feedback.temperature = .high
        default:
            feedback.temperature = .empty
        }
        
        if currentQuestionNo < questions.count {
            currentQuestionNo += 1
            updateUI()
            
            backgroundView.transform = CGAffineTransform(translationX: backgroundView.frame.size.width, y: 0)

            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        } else if currentQuestionNo == questions.count {
            self.performSegue(withIdentifier: feedbackReceivedSegue, sender: self)
        }
    }
    
    func updateUI(){
        if currentQuestionNo > 1 {
            backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        }
        question.text = questions[currentQuestionNo-1]
        pagesLabel.text = "\(currentQuestionNo)/\(questions.count)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        getQuestions()
    }
    
    func getQuestions(){
        networkService.getQuestions() { questions in
            
            self.questions = questions
            
            if let question = self.questions.first {
                self.question.text = question
                self.pagesLabel.text = "\(self.currentQuestionNo)/\(questions.count)"
            } else {
                self.question.text = "no questions"
            }
            print(questions)
        }
    }
}
