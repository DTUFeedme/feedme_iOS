//
//  FeedbackController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 26/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON
import SideMenuSwift

class FeedbackVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    private let userErrorMessage =  "Couldn't send feedback. Try again later 😐"
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var roomLocationLabel: UILabel!
    @IBOutlet weak var sideMenuTrailing: NSLayoutConstraint!
    @IBOutlet weak var sideMenu: UIView!
    private var isMenuShowing = false
    private var hasStartedLocation = false
    @IBOutlet weak var reloadInternetButton: UIButton!
    @IBOutlet weak var reloadInternetLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private let climifyApi = ClimifyAPI()
    private var questions: [Question] = []
    private var answers: [Question.answerOption] = []
    var currentRoomID: String = ""
    var currentRoomName: String = ""
    private var systemStatusMessage = ""
    private var currentQuestionNo = 0
    var userChangedRoomDelegate: UserChangedRoomDelegate!
    
    override func viewWillAppear(_ animated: Bool) {
        sideMenuTrailing.constant = -255
        restartFeedback()
        getQuestions()
        

        if hasStartedLocation {
            CoreLocation.sharedInstance.initTimerfetchRoom()
        }
        hasStartedLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CoreLocation.sharedInstance.stopTimerfetchRoom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        if checkConnectivity(){
            checkIfUserExists()
            updateUI()
            CoreLocation.sharedInstance.userChangedRoomDelegate = self
            CoreLocation.sharedInstance.startLocating()
            reloadUI()
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
          print(currentQuestionNo, questions.count)
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
           
            if checkConnectivity() {
                let feedback = Feedback(answerId: answerId, roomID: currentRoomID, questionId: questionId)
                climifyApi.postFeedback(feedback: feedback) { statusCode in
                    if statusCode == HTTPCode.SUCCES {
                        print("Succesfully posted feedback")
                    } else {
                        self.systemStatusMessage = self.userErrorMessage
                        self.reloadUI()
                        print("The statuscode is: ", statusCode)
                    }
                }
            }
            print(currentQuestionNo, questions.count)
            if currentQuestionNo == questions.count {
                 self.performSegue(withIdentifier: "feedbackreceived", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let currentCell = tableView.cellForRow(at: indexPath) as! AnswerCell
        currentCell.flash()
        postFeedback(index: indexPath.row)

    }
    
    private func reloadUI(){
//        let isConnected = ClimifyAPI.Connectivity.isConnectedToInternet
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
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        if currentQuestionNo > 0 {
            currentQuestionNo -= 1
            answers = questions[currentQuestionNo].answerOptions
            updateUI()
            animateSlideGesture(forward: false)
        }
    }
    
    private func restartFeedback(){
        currentQuestionNo = 0
        questions.removeAll()
    }
    
    private func checkIfUserExists(){
        if UserDefaults.standard.string(forKey: "x-auth-token") == nil {
            climifyApi.getToken() { statusCode in
                if statusCode == HTTPCode.SUCCES {
                    print("success")
                } else {
                    self.systemStatusMessage = self.userErrorMessage
                    self.reloadUI()
                    print("The statuscode is: ", statusCode)
                }
            }
        }
    }
    
    private func getQuestions(){
         climifyApi.getQuestions(currentRoomID: currentRoomID) { questions, statusCode in
            print(questions)
            if statusCode == HTTPCode.SUCCES {
                if questions.isEmpty {
                    self.systemStatusMessage = "No feedback is needed right now ☺️"
                    self.reloadUI()
                } else {
                    self.questions = questions
                    self.answers = questions[self.currentQuestionNo].answerOptions
                    self.reloadUI()
                    self.updateUI()
                    if let question = self.questions.first {
                        self.questionLabel.text = question.question
                        self.pagesLabel.text = "\(self.currentQuestionNo+1)/\(questions.count)"
                    }
                }
            } else {
                self.systemStatusMessage = "No feedback is needed right now ☺️"
                self.reloadUI()
                print("The statuscode is: ", statusCode)
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

extension FeedbackVC: UserChangedRoomDelegate {
    
    func userChangedRoom(roomname: String, roomid: String) {
        print("current: ", currentRoomID)
        print("input: ", roomid)
        if roomid.isEmpty {
            roomLocationLabel.text = "Couldn't estimate your location 🤔"
        } else if roomid != currentRoomID {
            currentRoomID = roomid
            currentRoomName = roomname
            restartFeedback()
            getQuestions()
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

