import UIKit
import Charts

class DataTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private let coreLocation = CoreLocation()
    private let climifyApi = ClimifyAPI()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mydataButton: UIButton!
    @IBOutlet weak var alldataButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var lastweekButton: UIButton!
    @IBOutlet weak var lastmonthButton: UIButton!
    @IBOutlet weak var alltimeButton: UIButton!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var choosenRoomLabel: UILabel!
    @IBOutlet weak var roomLocationLabel: UILabel!
    
    private var label = UILabel()
    
    struct Question {
        var question: String
        var questionId: String
        var answeredCount: Int
    }
    // maybe do as in portfolio light, if empty then show message
    private var questions: [Question] = [Question(question: "", questionId: "", answeredCount: 0)]
  
    private var hasGivenFeedback = false
    private var mydataIsSelected = true
    private var time = Time.all
    private var currentRoom = ""
    var currentRoomId = ""
    var chosenRoomId = ""
    private var chosenRoom = ""
    private var hasProvidedFeedback = true
    private var hasStartedLocating = false
    private var manuallyChangedRoom = false
    
    override func viewDidAppear(_ animated: Bool) {
        if hasStartedLocating {
            coreLocation.initTimerfetchRoom()
        }
        hasStartedLocating = true
        getAnsweredQuestions()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (ClimifyAPI.Connectivity.isConnectedToInternet){
            guard let _ = TOKEN else { return }
            coreLocation.userChangedRoomDelegate = self
            coreLocation.startLocating()
        }
        chosenRoom = currentRoom
        chosenRoomId = currentRoomId
        tableView.separatorColor = UIColor.clear
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        label.numberOfLines = 0
        label.center = self.view.center
        label.textAlignment = .justified
        label.text = "Woops. You have not given any feedback in this room yet. Please change room in the upper right corner or provide feedback 😎"
        label.font = .avenir18()
        label.textColor = .white
        self.view.addSubview(label)
        label.isHidden = true
    }
    
    func updateCurrentRoomIdLabel(){
        if !currentRoomId.isEmpty {
            roomLocationLabel.text = "You are in \(currentRoomId) 🙂"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coreLocation.stopTimerfetchRoom()
    }
    
    // BUTTONS
    @IBAction func alldataButtonAction(_ sender: Any) {
       
        if mydataIsSelected {
            animateSlideGesture(right: true)
        }
        mydataIsSelected = false
        getAnsweredQuestions()
    }
    @IBAction func changeRoomButton(_ sender: Any) {
        
        let roomChooserVC = storyboard?.instantiateViewController(withIdentifier: "roomchooser") as! RoomChooserController
        roomChooserVC.manuallyChangedRoomDelegate = self
        roomChooserVC.currentRoom = currentRoom
        
        present(roomChooserVC, animated: true, completion: nil)
    }
    
    @IBAction func timespanAction(_ sender: UIButton) {
        timeChanged(tag: sender.tag)
    }
    
    @IBAction func mydataButtonAction(_ sender: Any) {
        
        if !mydataIsSelected {
            animateSlideGesture(right: false)
        }
        mydataIsSelected = true
        getAnsweredQuestions()
    }
    
    // NETWORKING
    
    private func getAnsweredQuestions(){
        climifyApi.getAnsweredQuestions(roomID: chosenRoomId, time: time, me: mydataIsSelected) { questions, statusCode in
            if statusCode == HTTPCode.SUCCES {
                if questions.isEmpty {
                   self.hideUI()
                } else {
                    self.showUI()
                    self.hasGivenFeedback = true
                    var localQuestions: [Question] = []
                    for q in questions {
                        let question = Question(question: q.question, questionId: q.questionId, answeredCount: q.answeredCount)
                        localQuestions.append(question)
                    }
                    self.questions = localQuestions
                    self.tableView.reloadData()
                }
            } else {
                self.hideUI()
                print("The statuscode is: ", statusCode)
            }
        }
    }
    
    // HANDLE TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellQuestion", for: indexPath) as! QuestionCell
        cell.questionLabel.text = questions[indexPath.row].question
        cell.howManyTimesAnsweredLabel.text = String(questions[indexPath.row].answeredCount)        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! QuestionCell
        currentCell.flash()
        let diagramVC = storyboard?.instantiateViewController(withIdentifier: "diagramview") as! DiagramViewController
        diagramVC.room = chosenRoom
        diagramVC.meIsSelected = mydataIsSelected
        diagramVC.roomID = chosenRoomId
        diagramVC.time = time
        diagramVC.questionID = questions[indexPath.row].questionId
        diagramVC.question = questions[indexPath.row].question
        
        present(diagramVC, animated: true, completion: nil)
    }
    
    
    // UI
    private func timeChanged(tag: Int){
        switch tag {
        case 0:
            todayButton.pulsate()
            todayButton.titleLabel?.font = .avenir20()
            todayButton.setTitleColor(.white, for: .normal)
            
            lastweekButton.titleLabel?.font = .avenir18()
            lastweekButton.setTitleColor(.myCyan(), for: .normal)
            
            lastmonthButton.titleLabel?.font = .avenir18()
            lastmonthButton.setTitleColor(.myCyan(), for: .normal)
            
            alltimeButton.titleLabel?.font = .avenir18()
            alltimeButton.setTitleColor(.myCyan(), for: .normal)
            time = Time.day
        case 1:
            lastweekButton.pulsate()
            lastweekButton.titleLabel?.font = .avenir20()
            lastweekButton.setTitleColor(.white, for: .normal)
            
            todayButton.titleLabel?.font = .avenir18()
            todayButton.setTitleColor(.myCyan(), for: .normal)
            
            lastmonthButton.titleLabel?.font = .avenir18()
            lastmonthButton.setTitleColor(.myCyan(), for: .normal)
            time = Time.week
            
            alltimeButton.titleLabel?.font = .avenir18()
            alltimeButton.setTitleColor(.myCyan(), for: .normal)
        case 2:
            lastmonthButton.pulsate()
            lastmonthButton.titleLabel?.font = .avenir20()
            lastmonthButton.setTitleColor(.white, for: .normal)
            
            todayButton.titleLabel?.font = .avenir18()
            todayButton.setTitleColor(.myCyan(), for: .normal)
            
            lastweekButton.titleLabel?.font = .avenir18()
            lastweekButton.setTitleColor(.myCyan(), for: .normal)
            time = Time.month
            
            alltimeButton.titleLabel?.font = .avenir18()
            alltimeButton.setTitleColor(.myCyan(), for: .normal)
            
        case 3:
            alltimeButton.titleLabel?.font = .avenir20()
            alltimeButton.setTitleColor(.white, for: .normal)
            alltimeButton.pulsate()
            
            lastmonthButton.titleLabel?.font = .avenir18()
            lastmonthButton.setTitleColor(.myCyan(), for: .normal)
            
            todayButton.titleLabel?.font = .avenir18()
            todayButton.setTitleColor(.myCyan(), for: .normal)
            
            lastweekButton.titleLabel?.font = .avenir18()
            lastweekButton.setTitleColor(.myCyan(), for: .normal)
            time = Time.all
        default:
            break
        }
        getAnsweredQuestions()
//        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func showUI(){
        alltimeButton.isHidden = false
        tableView.isHidden = false
        mydataButton.isHidden = false
        alldataButton.isHidden = false
        todayButton.isHidden = false
        lastweekButton.isHidden = false
        lastmonthButton.isHidden = false
        slideView.isHidden = false
        roomLocationLabel.isHidden = false
        alltimeButton.isHidden = false
        label.isHidden = true
    }
    private func hideUI(){
       
//        roomLocationLabel.isHidden = true
        choosenRoomLabel.isHidden = true
        tableView.isHidden = true
        label.isHidden = false
        
        if !hasGivenFeedback {
            alltimeButton.isHidden = true
            slideView.isHidden = true
            alldataButton.isHidden = true
            todayButton.isHidden = true
            lastweekButton.isHidden = true
            lastmonthButton.isHidden = true
            mydataButton.isHidden = true
        }
    }
    
    private func animateSlideGesture(right: Bool){
        if right {
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                            self.slideView.transform = CGAffineTransform(translationX: self.slideView.frame.size.width+2, y: 0)
            })
            tableView.transform = CGAffineTransform(translationX: tableView.frame.size.width*2, y: 0)
            alldataButton.setTitleColor(.white, for: .normal)
            mydataButton.setTitleColor(.myDark(), for: .normal)
        } else {
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                            self.slideView.transform = CGAffineTransform(translationX: 0, y: 0)
            })
            tableView.transform = CGAffineTransform(translationX: -tableView.frame.size.width*2, y: 0)
            alldataButton.setTitleColor(.myDark(), for: .normal)
            mydataButton.setTitleColor(.white, for: .normal)
        }
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.tableView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        
    }
}

// PROTOCOLS AND DELEGATES
extension DataTabController: ManuallyChangedRoomDelegate {
    func roomchanged(roomname: String, roomid: String) {
        manuallyChangedRoom = true
        chosenRoom = roomname
        chosenRoomId = roomid
        choosenRoomLabel.text = "showing questions answered from \(roomname)"
        getAnsweredQuestions()
    }
}
extension DataTabController: UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String) {
        currentRoom = roomname
        currentRoomId = roomid
        roomLocationLabel.text = "You are in \(roomid) 🙂"
        
        if !manuallyChangedRoom {
            chosenRoom = roomname
            chosenRoomId = roomid
            choosenRoomLabel.text =  "showing questions answered from \(roomname)"
            getAnsweredQuestions()
        }
    }
}
