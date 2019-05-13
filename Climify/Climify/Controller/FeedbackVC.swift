//
//  FeedbackController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 26/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedbackVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var roomLocationLabel: UILabel!
    @IBOutlet weak var sideMenuTrailing: NSLayoutConstraint!
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var reloadInternetButton: UIButton!
    @IBOutlet weak var reloadInternetLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let userErrorMessage =  "Couldn't send feedback. Try again later 😐"
    private var questions: [Question] = []
    private var answers: [Question.answerOption] = []
    private var systemStatusMessage = ""
    private var currentQuestionNo = 0
    private var isMenuShowing = false
    private var hasStartedLocation = false
    var currentRoomID: String = ""
    var currentRoomName: String = ""
    var userChangedRoomDelegate: FoundNewRoomProtocol!

    
    override func viewDidAppear(_ animated: Bool) {
        sideMenuTrailing.constant = -255
        restartFeedback()
        fetchQuestions()
        
        if hasStartedLocation {
            LocationEstimator.sharedInstance.userChangedRoomDelegate = self
            LocationEstimator.sharedInstance.initTimerfetchRoom()
        }
        hasStartedLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        LocationEstimator.sharedInstance.stopTimerfetchRoom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        if checkConnectivity(){
            checkIfUserExists() { wentWell in
                if wentWell {
                    self.updateUI()
                    LocationEstimator.sharedInstance.userChangedRoomDelegate = self
                    LocationEstimator.sharedInstance.startLocating()
                    self.reloadUI()
                }
            }
        }
    }
    
    func setupUI(){
        tableView.separatorColor = UIColor.clear
        sideMenu.layer.shadowOpacity = 1
        sideMenu.layer.shadowRadius = 6
    }
    
    
    @IBAction func sideMenuAction(_ sender: Any) {
        if isMenuShowing {
            sideMenuTrailing.constant = -255
        } else {
            sideMenuTrailing.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        isMenuShowing = !isMenuShowing
    }
    
    private func updateUI(){
        if let text = questions[safe: currentQuestionNo]?.question {
            questionLabel.text = text
            pagesLabel.text = "\(currentQuestionNo+1)/\(questions.count)"
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAnswer", for: indexPath) as! AnswerCell
        if let text = answers[safe:indexPath.row]?.value {
            cell.answerLabel.text = text
            return cell
        } else {
            return cell
        }
    }
    
    private func checkConnectivity() -> Bool{
        if !ClimifyAPI.Connectivity.isConnectedToInternet {
            restartFeedback()
            updateUI()
            reloadUI()
        }
        return ClimifyAPI.Connectivity.isConnectedToInternet
    }
    
    private func postFeedback(index: Int){
        if checkConnectivity() {
            if currentQuestionNo < questions.count {
                
                let questionId = questions[currentQuestionNo].id
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
                
                let feedback = Feedback(answerId: answerId, roomID: currentRoomID, questionId: questionId)
                ClimifyAPI.sharedInstance.postFeedback(feedback: feedback) { error in
                    if error == nil  {
                        if self.currentQuestionNo == self.questions.count {
                            self.performSegue(withIdentifier: "feedbackreceived", sender: self)
                        }
                    } else {
                        self.answers.removeAll()
                        self.tableView.reloadData()
                        self.systemStatusMessage = self.userErrorMessage
                        self.reloadUI()
                    }
                }
            }
        } else {
            self.answers.removeAll()
            self.tableView.reloadData()
            self.systemStatusMessage = self.userErrorMessage
            self.reloadUI()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let currentCell = tableView.cellForRow(at: indexPath) as! AnswerCell
        currentCell.flash()
        postFeedback(index: indexPath.row)
    }
    
    private func reloadUI(){
        if ClimifyAPI.Connectivity.isConnectedToInternet == false {
            questionLabel.text = "Please make sure you have internet connection 🤔"
            reloadInternetLabel.isHidden = false
            reloadInternetButton.isHidden = false
        } else if currentRoomID == "" {
            questionLabel.text = "Couldn't estimate your location..."
            roomLocationLabel.text = "Trying to estimate your location 🤔"
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
        reloadInternetLabel.text = "Are you sure you are connected? 🤔"
        viewDidLoad()
    }
    private func restartFeedback(){
        currentQuestionNo = 0
        questions.removeAll()
    }
    
    private func checkIfUserExists(completion: @escaping (_ didExist: Bool) -> Void) {
        
        if UserDefaults.standard.string(forKey: "x-auth-token") == nil {
            ClimifyAPI.sharedInstance.fetchToken() { error in
                if error == nil {
                    completion(true)
                } else {
                    self.systemStatusMessage = self.userErrorMessage
                    self.reloadUI()
                    completion(false)
                }
            }
        } else {
            completion(true)
        }
    }
    
    private func fetchQuestions(){
         ClimifyAPI.sharedInstance.fetchQuestions(currentRoomID: currentRoomID) { questions, error in
            if error == nil {
                self.questions = questions!
                self.answers = questions![self.currentQuestionNo].answerOptions
                self.reloadUI()
                // test det her
                self.tableView.reloadData()
                self.updateUI()
                if let question = self.questions.first {
                    self.questionLabel.text = question.question
                    self.pagesLabel.text = "\(self.currentQuestionNo+1)/\(questions!.count)"
                }
            } else {
                self.systemStatusMessage = "No feedback is needed right now ☺️"
                self.reloadUI()
            }
        }
    }
    
    // UI and Extensions...
    private func animateSlideGesture(forward: Bool){
        
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
    
    func updateCurrentRoomNameLabel() {
        roomLocationLabel.text = "You are in \(currentRoomName) 🙂"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
                return .lightContent
    }
}

extension FeedbackVC: FoundNewRoomProtocol {
    
    func userChangedRoom(roomname: String, roomid: String) {
        if roomid.isEmpty {
            roomLocationLabel.text = "Couldn't estimate your location 🤔"
        } else if roomid != currentRoomID {
            currentRoomID = roomid
            currentRoomName = roomname
            restartFeedback()
            fetchQuestions()
            reloadUI()
            roomLocationLabel.text = "You are in \(roomname) 🙂"
        }
        currentRoomID = roomid
        currentRoomName = roomname
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

