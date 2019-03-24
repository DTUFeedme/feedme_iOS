//
//  FeedbackController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 26/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedbackController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let feedbackReceivedSegue = "feedbackreceived"
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var roomLocationLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var reloadInternetButton: UIButton!
    @IBOutlet weak var reloadInternetLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let networkService = NetworkService()
    let coreLocationController = CoreLocationController()
    
    var questions: [Question] = []
    var answers: [String] = []
    
    var currentRoomID: String = "isEmpty"
    var systemStatusMessage = ""
    var currentQuestionNo = 0
 
    var isFeedbackInitiated = false
    var feedback:Feedback? = nil
    
    var delegate: UserChangedRoomDelegate!
    
    override func viewDidAppear(_ animated: Bool) {
        reloadUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.clear
        
        if (NetworkService.Connectivity.isConnectedToInternet){
            checkIfUserExists()
            coreLocationController.userChangedDelegate = self
            coreLocationController.startLocating()
            reloadUI()
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
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAnswer", for: indexPath) as! AnswerCell
        cell.answerLabel.text = answers[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isFeedbackInitiated {
            feedback = Feedback.init()
            isFeedbackInitiated = true
        }
        
        let currentCell = tableView.cellForRow(at: indexPath) as! AnswerCell
        currentCell.flash()
        
        if currentQuestionNo < questions.count {
            
            let id = questions[currentQuestionNo].questionID
            let answer = answers[indexPath.row]

            if let tempFeedback = feedback {
                tempFeedback.answers.append(Answer(questionID: id, answer: answer))
            }
            if currentQuestionNo < questions.count-1 {
                currentQuestionNo += 1
                animateSlideGesture(forward: true)
                answers = questions[currentQuestionNo].answerOptions
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.updateUI()
                    self.tableView.reloadData()
                }
                
            } else if currentQuestionNo >= questions.count-1 {
                if let tempFeedback = feedback {
                    
                    tempFeedback.roomID = currentRoomID
                    
                    if !NetworkService.Connectivity.isConnectedToInternet {
                        restartFeedback()
                        updateUI()
                        reloadUI()
                        return
                    }
                    networkService.postFeedback(feedback: tempFeedback) { statusCode in
                        switch statusCode {
                        case HTTPCode.SUCCES:
                            self.performSegue(withIdentifier: self.feedbackReceivedSegue, sender: self)
                        case HTTPCode.CLIENTERROR...499:
                            self.systemStatusMessage = "Couldn't send feedback. Try again later..."
                            self.reloadUI()
                            print("Client error when getting posting feedback")
                        case HTTPCode.SERVERERROR...599:
                            self.systemStatusMessage = "Couldn't send feedback. Try again later..."
                            self.reloadUI()
                            print("Server error when getting posting feedback")
                        default:
                            self.systemStatusMessage = "Something went wrong. Try again later..."
                            self.reloadUI()
                            print("3 Something's way off: \(statusCode)")
                        }
                        self.questionLabel.text = self.systemStatusMessage
                    }
                }
            }
        }
        
    }
    
    func reloadUI(){
        let isConnected = NetworkService.Connectivity.isConnectedToInternet
        if isConnected == false {
            questionLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 28)
            questionLabel.textAlignment = NSTextAlignment.left
            questionLabel.text = "Please make sure you have internet connection..."
            reloadInternetLabel.isHidden = false
            reloadInternetButton.isHidden = false
        } else if currentRoomID == "isEmpty" {
            questionLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 28)
            questionLabel.textAlignment = NSTextAlignment.left
            questionLabel.text = "Couldn't estimate your location..."
            roomLocationLabel.text = "Trying to estimate your location..."
            reloadInternetLabel.isHidden = true
            reloadInternetButton.isHidden = true
        } else if questions.isEmpty {
            questionLabel.text = systemStatusMessage
            reloadInternetLabel.isHidden = true
            reloadInternetButton.isHidden = true
        } else {
            reloadInternetLabel.isHidden = true
            reloadInternetButton.isHidden = true
        }
    }
    
    @IBAction func reloadIfConnected(_ sender: Any) {
        reloadInternetButton.rotateImage()
        reloadInternetLabel.text = "Are you sure you are connected?"
        viewDidLoad()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        if currentQuestionNo > 0 {
            
            currentQuestionNo -= 1
            answers = questions[currentQuestionNo].answerOptions
            if let tempFeedback = feedback{
                tempFeedback.answers.remove(at: currentQuestionNo)
            }
            updateUI()
            animateSlideGesture(forward: false)
        }
    }
    
    func restartFeedback(){
        currentQuestionNo = 0
        questions.removeAll()
        isFeedbackInitiated = false
    }
    
    func checkIfUserExists(){
        if let userID = UserDefaults.standard.string(forKey: "userID") {
            print(userID)
        } else {
            networkService.initUser() { statusCode in
                switch statusCode {
                case HTTPCode.SUCCES:
                    self.feedback = Feedback.init()
                case HTTPCode.CLIENTERROR...499:
                    self.systemStatusMessage = "Something went wrong. Try again later..."
                    self.reloadUI()
                    print("Client error when getting the questions")
                case HTTPCode.SERVERERROR...599:
                    self.systemStatusMessage = "Something went wrong. Try again later..."
                    self.reloadUI()
                    print("Server error when getting the questions")
                default:
                    self.systemStatusMessage = "Something went wrong. Try again later..."
                    self.reloadUI()
                    print("1 Something's way off: \(statusCode)")
                }
            }
        }
    }
    
    func getQuestions(){
         networkService.getQuestions(currentRoomID: currentRoomID) { questions, statusCode in
            print(questions)
            switch statusCode {
            case HTTPCode.SUCCES...299:
                if questions.isEmpty {
                    self.systemStatusMessage = "No feedback is needed right now..."
                    self.reloadUI()
                } else {
                    self.questions = questions
                    self.answers = questions[self.currentQuestionNo].answerOptions
                    self.reloadUI()
                    self.updateUI()
                    self.tableView.reloadData()
                    
                    if let question = self.questions.first {
                        self.questionLabel.text = question.question
                        self.pagesLabel.text = "\(self.currentQuestionNo+1)/\(questions.count)"
                    }
                }
            case HTTPCode.CLIENTERROR...499:
                self.systemStatusMessage = "Something went wrong. Try again later..."
                self.reloadUI()
                print("Client error when getting the questions")
            case HTTPCode.SERVERERROR...599:
                self.systemStatusMessage = "Something went wrong. Try again later..."
                self.reloadUI()
                print("Server error when getting the questions")
            default:
                self.systemStatusMessage = "Something went wrong. Try again later..."
                self.reloadUI()
                print("2 Something's way off: \(statusCode)")
            }
        }
    }
    
    
    func animateSlideGesture(forward: Bool){
        
        if forward {
            UIView.animate(withDuration: 0,
                           delay: 0.25,
                           options: .curveEaseInOut,
                           animations: {
                            self.backgroundView.transform = CGAffineTransform(translationX: self.backgroundView.frame.size.width*2, y: 0)
            })
        } else {
             backgroundView.transform = CGAffineTransform(translationX: -backgroundView.frame.size.width*2, y: 0)
        }
        UIView.animate(withDuration: 0.75,
                       delay: 0.35,
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
        currentRoomID = roomid
        roomLocationLabel.text = "you are located in \(roomname)"
        restartFeedback()
        getQuestions()
        reloadUI()
    }
}
