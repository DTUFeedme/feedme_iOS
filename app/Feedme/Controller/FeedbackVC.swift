//
//  FeedbackController.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 26/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class FeedbackVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
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
    private var answers: [Option] = []
    private var systemStatusMessage = ""
    private var currentQuestionNo = 0
    private var isMenuShowing = false
    private var hasStartedLocation = false
    var currentRoomID: String = ""
    var currentRoomName: String = ""
    var userChangedRoomDelegate: FoundNewRoomProtocol!
    var feedmeNS: FeedmeNetworkService!
    var locationEstimator: LocationEstimator!
    
    override func viewDidAppear(_ animated: Bool) {
        restartFeedback()
        fetchQuestions()
        isLoggedIn()
        
        if hasStartedLocation {
           locationEstimator.userChangedRoomDelegate = self
           locationEstimator.initTimerfetchRoom()
        }
        hasStartedLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       locationEstimator.stopTimerfetchRoom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedmeNS = appDelegate.feedmeNS
        locationEstimator = appDelegate.locationEstimator
        setupUI()
        
        if checkConnectivity() {
            checkIfUserExists() { _ in
                print("yo")
                self.updateQuestionsUI()
                self.locationEstimator.userChangedRoomDelegate = self
                self.locationEstimator.startLocating()
                self.reloadUI()
            }
        }
    }
    @IBAction func login(_ sender: Any) {
        if loginButton.title == "Logout" {
            UserDefaults.standard.removeObject(forKey: "isAdmin")
            
            if let tbc = self.tabBarController as? TabBarVC {
                tbc.removeTabBarItem()
                loginButton.title = "Login"
            }
        } else {
            self.performSegue(withIdentifier: "login", sender: nil)
        }
    }
    
    func isLoggedIn(){
        if UserDefaults.standard.contains(key: "isAdmin") {
            if let tbc = self.tabBarController as? TabBarVC {
                if tbc.viewControllers?.count == 2 {
                    tbc.addNewTabBarItem()
                }
            }
            loginButton.title = "Logout"
        } else {
            loginButton.title = "Login"
        }
    }
    
    
    // FUNCTIONALITY FOR WHEN A SIDEMENU IS NEEDED
//    @IBAction func sideMenuAction(_ sender: Any) {
//        if isMenuShowing {
//            sideMenuTrailing.constant = -255
//        } else {
//            if UserDefaults.standard.contains(key: "isAdmin") {
//
//            }
//            sideMenuTrailing.constant = 0
//            UIView.animate(withDuration: 0.3, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
//        isMenuShowing = !isMenuShowing
//    }
    
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
        if !FeedmeNetworkService.Connectivity.isConnectedToInternet {
            restartFeedback()
            updateQuestionsUI()
            reloadUI()
        }
        return FeedmeNetworkService.Connectivity.isConnectedToInternet
    }
    
    private func postFeedback(index: Int){
        if checkConnectivity() {
            if currentQuestionNo < questions.count {
                
                let questionId = questions[currentQuestionNo]._id
                let answerId = answers[index]._id
                prepareForNextQuestion()
                let feedback = Feedback(answerId: answerId, roomID: currentRoomID, questionId: questionId)
                feedmeNS.postFeedback(feedback: feedback) { error in
                    if error == nil  {
                        if self.currentQuestionNo == self.questions.count {
                            self.performSegue(withIdentifier: "feedbackreceived", sender: self)
                        }
                    } else {
                        self.restart()
                    }
                }
            }
        } else {
            restart()
        }
    }
    
    func restart(){
        self.answers.removeAll()
        self.restartFeedback()
        self.tableView.reloadData()
        self.systemStatusMessage = self.userErrorMessage
        self.reloadUI()
    }
  
    func prepareForNextQuestion(){
        if currentQuestionNo < questions.count-1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.answers = self.questions[self.currentQuestionNo].answerOptions
                self.updateQuestionsUI()
                self.tableView.reloadData()
            }
        }
        currentQuestionNo += 1
        animateSlideGesture(forward: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let currentCell = tableView.cellForRow(at: indexPath) as! AnswerCell
        currentCell.flash()
        postFeedback(index: indexPath.row)
    }
    
    private func restartFeedback(){
        currentQuestionNo = 0
        questions.removeAll()
    }
    
    private func checkIfUserExists(completion: @escaping (_ didExist: Bool) -> Void) {
        
        if UserDefaults.standard.string(forKey: "x-auth-token") == nil ||
            UserDefaults.standard.string(forKey: "refreshToken") == nil{
            print("auth token null")
            feedmeNS.fetchToken() { error in
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

         feedmeNS.fetchQuestions(currentRoomID: currentRoomID) { questions, error in
            if error == nil {
                self.questions = questions!
                self.answers = questions![self.currentQuestionNo].answerOptions
                self.reloadUI()
                self.updateQuestionsUI()
                return
            } else if (error?.errorDescription == "401"){
                self.feedmeNS.refreshToken { (error) in
                    if error == nil {
                        self.feedmeNS.fetchQuestions(currentRoomID: self.currentRoomID) { (quetions, error) in
                            if (error == nil){
                                self.questions = questions!
                                self.answers = questions![self.currentQuestionNo].answerOptions
                                self.updateQuestionsUI()
                                self.reloadUI()
                                return
                            }
                        }
                    }
                }
            }
            self.questions = []
            self.answers = []
            self.tableView.reloadData()
            self.systemStatusMessage = "No feedback is needed right now ☺️"
            self.reloadUI()
        }
    }
    
    // UI and Extensions...
    private func updateQuestionsUI(){
        if let text = questions[safe: currentQuestionNo]?.value {
            questionLabel.text = text
            pagesLabel.text = "\(currentQuestionNo+1)/\(questions.count)"
            tableView.reloadData()
        }
    }
    
    private func setupUI(){
        tableView.separatorColor = UIColor.clear
    }
    
    private func reloadUI(){
        if FeedmeNetworkService.Connectivity.isConnectedToInternet == false {
            questionLabel.text = "Please make sure you have internet connection 🤔"
            reloadInternetOutlet(hide: false)
            return
        } else if currentRoomID == "" {
            questionLabel.text = "Couldn't estimate your location..."
            roomLocationLabel.text = "Trying to estimate your location 🤔"
        } else if questions.isEmpty {
            pagesLabel.text = ""
            questionLabel.text = systemStatusMessage
        }
        reloadInternetOutlet(hide: true)
    }
    
    func reloadInternetOutlet(hide: Bool){
        reloadInternetLabel.isHidden = hide
        reloadInternetButton.isHidden = hide
    }
    
    @IBAction func reloadIfConnected(_ sender: Any) {
        reloadInternetButton.rotateImage()
        viewDidLoad()
    }
    
    
    
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
        if currentRoomID.isEmpty {
            roomLocationLabel.text = "Trying to estimate your location 🤔"
        } else {
            roomLocationLabel.text = "You are in \(currentRoomName) 🙂"
        }
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
            updateCurrentRoomNameLabel()
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

