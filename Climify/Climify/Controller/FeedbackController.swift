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
    
    @IBOutlet weak var roomLocationLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    
    @IBOutlet weak var reloadInternetButton: UIButton!
    @IBOutlet weak var reloadInternetLabel: UILabel!
    var currentRoomID: String = ""
    let networkService = NetworkService()
    var currentQuestionNo = 0
//    var rotateButton:Double = 0.99
    var questions: [Question] = []
    var isFeedbackInitiated = false
    var feedback:Feedback? = nil
    let coreLocationController = CoreLocationController()
    var delegate: UserChangedRoomDelegate!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func reloadIfConnected(_ sender: Any) {
        reloadInternetButton.rotateImage()
        reloadInternetLabel.text = "Are you sure you are \nconnected?"
//        rotateButton+=1
        viewDidLoad()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        if currentQuestionNo > 0 {
        currentQuestionNo -= 1
            if let tempFeedback = feedback{
                tempFeedback.answers.remove(at: currentQuestionNo)
            }
        updateUI()
        animateSlideGesture(forward: false)
        }
    }
    
    func reloadUI(){
        let isConnected = NetworkService.Connectivity.isConnectedToInternet
        print(isConnected)
        if isConnected == false {
            self.questionLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 24)
            self.questionLabel.textAlignment = NSTextAlignment.left
            self.questionLabel.text = "Please make sure you have internet connection..."
            self.buttonOne.isHidden = true
            self.buttonTwo.isHidden = true
            self.buttonThree.isHidden = true
            self.reloadInternetLabel.isHidden = false
            self.reloadInternetButton.isHidden = false
            activityIndicator.stopAnimating()
        } else if currentRoomID == "" {
            self.questionLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 24)
            self.questionLabel.textAlignment = NSTextAlignment.left
            self.questionLabel.text = "Couldn't estimate your location..."
            self.roomLocationLabel.text = "estimating you location..."
            self.buttonOne.isHidden = true
            self.buttonTwo.isHidden = true
            self.buttonThree.isHidden = true
            self.reloadInternetLabel.isHidden = true
            self.reloadInternetButton.isHidden = true
            activityIndicator.startAnimating()
        } else {
            self.buttonOne.isHidden = false
            self.buttonTwo.isHidden = false
            self.buttonThree.isHidden = false
            self.reloadInternetLabel.isHidden = true
            self.reloadInternetButton.isHidden = true
            activityIndicator.stopAnimating()
            
        }
    }
    
    @IBAction func temperatureFeedback(_ sender: UIButton) {
        
        if !isFeedbackInitiated {
            feedback = Feedback.init()
            isFeedbackInitiated = true
        }
        
        if currentQuestionNo < questions.count {
            
            let id = questions[currentQuestionNo].questionID
            var answer = 0
            
            switch sender.tag {
            case 0:
                answer = 1
            case 1:
                answer = 2
            case 2:
                answer = 3
            default:
                print("default")
            }
            sender.flash()
            if let tempFeedback = feedback {
                tempFeedback.answers.append(Answer(questionID: id, answer: answer))
            }
            if currentQuestionNo < questions.count-1 {
            
                currentQuestionNo += 1
                updateUI()
                animateSlideGesture(forward: true)
                
            } else if currentQuestionNo >= questions.count-1 {
                if let tempFeedback = feedback {
                    
                    tempFeedback.roomID = currentRoomID
                    
                    networkService.postFeedback(feedback: tempFeedback)
                    self.performSegue(withIdentifier: feedbackReceivedSegue, sender: self)
                }
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
    
    override func viewDidAppear(_ animated: Bool) {
        reloadUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocationController.userChangedDelegate = self
        
        if (NetworkService.Connectivity.isConnectedToInternet){
            checkIfUserExists()
            coreLocationController.startLocating()
        } else {
            reloadUI()
        }
    }
    
    func checkIfUserExists(){
        let defaults = UserDefaults.standard
        
        if let userID = defaults.string(forKey: "userID") {
            print(userID)
        } else {
            networkService.initUser() { result in
                if result == "success" {
                    self.feedback = Feedback.init()
                } else {
                    print("no connection right now")
                }
            }
        }
    }
    
    func getQuestions(){
         networkService.getQuestions(currentRoomID: currentRoomID) { questions in
            self.questions.removeAll()
            self.questions = questions
            self.reloadUI()
            
            if let question = self.questions.first {
                self.questionLabel.text = question.question
                self.pagesLabel.text = "\(self.currentQuestionNo+1)/\(questions.count)"
            }
        }
    }
    
    func animateSlideGesture(forward: Bool){
        
        if forward {
        backgroundView.transform = CGAffineTransform(translationX: backgroundView.frame.size.width*2, y: 0)
        } else {
             backgroundView.transform = CGAffineTransform(translationX: -backgroundView.frame.size.width*2, y: 0)
        }
        UIView.animate(withDuration: 0.5,
                       delay: 0.25,
                       options: .curveEaseInOut,
                       animations: {
                        self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension FeedbackController: UserChangedRoomDelegate {
    
    func userChangedRoom(roomname: String, roomid: String) {
        roomLocationLabel.text = "you are in room \(roomname)"
        currentRoomID = roomid
        self.questions.removeAll()
        getQuestions()
        reloadUI()
    }
}


