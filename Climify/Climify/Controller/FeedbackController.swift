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
    var feedback = Feedback.init()
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        
        if currentQuestionNo > 0 {
        
        currentQuestionNo -= 1
        feedback.answers.remove(at: currentQuestionNo)
        
        updateUI()
        animateSlideGesture(forward: false)
            
        }
    }
    
    @IBAction func temperatureFeedback(_ sender: UIButton) {
        

        if currentQuestionNo < questions.count {
            
            let id = questions[currentQuestionNo].questionID
            var answer = "00000000"
            
            switch sender.tag {
            case 0:
                answer = "111111"
            case 1:
                answer = "222222"
            case 2:
                answer = "3333333333"
            default:
                print("default")
            }
            feedback.answers.append(Answer(questionID: id, answer: answer))
            
            if currentQuestionNo < questions.count-1 {
            
                currentQuestionNo += 1
                updateUI()
                animateSlideGesture(forward: true)
                
            } else if currentQuestionNo >= questions.count-1 {
                print(feedback.userID)
                feedback.roomID = "5c8140f9ac7aa950167d9167"
                networkService.postFeedback(feedback: feedback)
                self.performSegue(withIdentifier: feedbackReceivedSegue, sender: self)
            }
        }
    }
    
    func updateUI(){
        if currentQuestionNo < 1 {
            backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        } else {
            backButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
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
    
    func animateSlideGesture(forward: Bool){
        
        if forward {
        backgroundView.transform = CGAffineTransform(translationX: backgroundView.frame.size.width, y: 0)
        } else {
             backgroundView.transform = CGAffineTransform(translationX: -backgroundView.frame.size.width, y: 0)
        }
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
}
