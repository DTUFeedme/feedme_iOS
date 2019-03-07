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
    let feedbackReceivedSegue = "feedbackreceived"
    
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    let networkService = NetworkService()
    var currentQuestionNo = 0
    var questions: [Question] = []
    var feedback: [Feedback] = []
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        
        if currentQuestionNo > 0 {
        
        currentQuestionNo -= 1
        feedback.remove(at: currentQuestionNo)
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
        
        if currentQuestionNo < questions.count-1 {
            
            let id = questions[currentQuestionNo].questionID
            var answer = -1
            
            switch sender.tag {
            case 0:
                answer = sender.tag
            case 1:
                answer = sender.tag
            case 2:
                answer = sender.tag
            default:
                print("default")
            }
            feedback.append(Feedback(questionID: id, answer: answer))
            
            
            currentQuestionNo += 1
            updateUI()
            
            backgroundView.transform = CGAffineTransform(translationX: backgroundView.frame.size.width, y: 0)

            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        } else if currentQuestionNo == questions.count-1 {
            postFeedback()
            self.performSegue(withIdentifier: feedbackReceivedSegue, sender: self)
        }
    }
    
    func updateUI(){
        if currentQuestionNo >= 1 {
            backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        }
        
        questionLabel.text = questions[currentQuestionNo].question
        pagesLabel.text = "\(currentQuestionNo+1)/\(questions.count)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getQuestions()
    }
    
    func getQuestions(){
        networkService.getQuestions() { questions in
            
            self.questions = questions
            
            if let question = self.questions.first {
                self.questionLabel.text = question.question
                self.pagesLabel.text = "\(self.currentQuestionNo+1)/\(questions.count)"
            } else {
                self.questionLabel.text = "no questions"
                self.buttonOne.isHidden = true
                self.buttonTwo.isHidden = true
                self.buttonThree.isHidden = true
                
            }
        }
    }
    
    func postFeedback(){
        for ele in feedback {
            print("Question ID: ",ele.questionID)
            print("User ID:",ele.userID)
            print("Answer: ",ele.answer)
            print("------")
        }
    }
}
