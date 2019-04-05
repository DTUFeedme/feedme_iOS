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
    let userErrorMessage =  "Couldn't send feedback. Try again later..."
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
    var answers: [Question.answerOption] = []
    var currentRoomID: String = ""
    var systemStatusMessage = ""
    var currentQuestionNo = 0
    var delegate: UserChangedRoomDelegate!
    
    override func viewDidAppear(_ animated: Bool) {
        reloadUI()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.clear

        if checkConnectivity(){
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
        print(questions[currentQuestionNo].question)
        questionLabel.text = questions[currentQuestionNo].question
        pagesLabel.text = "\(currentQuestionNo+1)/\(questions.count)"
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAnswer", for: indexPath) as! AnswerCell
        cell.answerLabel.text = answers[indexPath.row].value
        return cell
        
    }
    
    func checkConnectivity() -> Bool{
        if !NetworkService.Connectivity.isConnectedToInternet {
            restartFeedback()
            updateUI()
            reloadUI()
            return false
        } else {
            return true
        }
    }
    
    func postFeedback(index: Int){
        
        if currentQuestionNo < questions.count {
            
            let questionId = questions[currentQuestionNo].questionID
            let answerId = answers[index].id
            
            if currentQuestionNo < questions.count-1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.answers = self.questions[self.currentQuestionNo].answerOptions
                    self.updateUI()
                    self.tableView.reloadData()
                }
            }
            currentQuestionNo += 1
            animateSlideGesture(forward: true)
           
            if checkConnectivity() {
                let feedback = Feedback(answerId: answerId, roomID: currentRoomID, questionId: questionId)
                networkService.postFeedback(feedback: feedback) { statusCode in
                    if statusCode == HTTPCode.SUCCES {
                        print("Succesfully posted feedback")
                    } else {
                        self.systemStatusMessage = self.userErrorMessage
                        self.reloadUI()
                        print("The statuscode is: ", statusCode)
                    }
                }
            }
            if currentQuestionNo == questions.count {
                 self.performSegue(withIdentifier: self.feedbackReceivedSegue, sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let currentCell = tableView.cellForRow(at: indexPath) as! AnswerCell
        currentCell.flash()
        postFeedback(index: indexPath.row)

    }
    
    func reloadUI(){
//        let isConnected = NetworkService.Connectivity.isConnectedToInternet
        if NetworkService.Connectivity.isConnectedToInternet == false {
            questionLabel.text = "Please make sure you have internet connection..."
            reloadInternetLabel.isHidden = false
            reloadInternetButton.isHidden = false
        } else if currentRoomID == "isEmpty" {
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
            updateUI()
            animateSlideGesture(forward: false)
        }
    }
    
    func restartFeedback(){
        currentQuestionNo = 0
        questions.removeAll()
    }
    
    func checkIfUserExists(){
        if TOKEN == nil {
            networkService.getToken() { statusCode in
                if statusCode == HTTPCode.SUCCES {
                    self.coreLocationController.userChangedDelegate = self
                    self.coreLocationController.startLocating()
                } else {
                    self.systemStatusMessage = self.userErrorMessage
                    self.reloadUI()
                    print("The statuscode is: ", statusCode)
                }
            }
        }
    }
    
    func getQuestions(){
         networkService.getQuestions(currentRoomID: currentRoomID) { questions, statusCode in
            
            if statusCode == HTTPCode.SUCCES {
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
            } else {
                self.systemStatusMessage = self.userErrorMessage
                self.reloadUI()
                print("The statuscode is: ", statusCode)
            }
        }
    }
    
    // UI and Extensions...
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
        roomLocationLabel.text = "You are in \(roomname) 🙂"
        restartFeedback()
        getQuestions()
        reloadUI()
    }
}


extension UITabBarController {
    open override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}

