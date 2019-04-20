import UIKit
import Charts

class DataTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let coreLocationController = CoreLocation()
    let networkService = NetworkService()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mydataButton: UIButton!
    @IBOutlet weak var alldataButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var lastweekButton: UIButton!
    @IBOutlet weak var lastmonthButton: UIButton!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var choosenRoomLabel: UILabel!
    @IBOutlet weak var roomLocationLabel: UILabel!
    var label = UILabel()
    
    struct Question {
        var question: String
        var questionId: String
        var answeredCount: Int
    }
    var questions: [Question] = [Question(question: "", questionId: "", answeredCount: 0)]
  
    var mydataIsSelected = true
    var time = "month"
    var currentRoom = ""
    var currentRoomId = ""
    var choosenRoomId = ""
    var choosenRoom = ""
    var hasProvidedFeedback = true
    var manuallyChangedRoom = false
    
    override func viewDidAppear(_ animated: Bool) {
        getAnsweredQuestions()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.clear
        
        if (NetworkService.Connectivity.isConnectedToInternet){
            guard let _ = TOKEN else { return }
            coreLocationController.userChangedDelegate = self
            coreLocationController.startLocating()
            //getAnsweredQuestions()
        }
        choosenRoom = currentRoom
        tableView.separatorColor = UIColor.clear
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.numberOfLines = 0
        label.center = self.view.center
        label.textAlignment = .center
        label.text = "Please give feedback before you can see feedback"
        label.font = .avenir20()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        self.view.addSubview(label)
        label.isHidden = true
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
        roomChooserVC.delegate = self
        roomChooserVC.chosenRoom = choosenRoom
        
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
    
    func getAnsweredQuestions(){
        networkService.getAnsweredQuestions(roomID: choosenRoomId, time: time, me: mydataIsSelected) { questions, statusCode in
            print(questions)
            if statusCode == HTTPCode.SUCCES {
                if questions.isEmpty {
                   self.hideUI()
                } else {
                    self.showUI()
                    self.questions = questions
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
        diagramVC.room = choosenRoom
        diagramVC.meIsSelected = mydataIsSelected
        diagramVC.roomID = choosenRoomId
        diagramVC.time = time
        diagramVC.questionID = questions[indexPath.row].questionId
        diagramVC.question = questions[indexPath.row].question
        
        present(diagramVC, animated: true, completion: nil)
    }
    
    // UI
    func timeChanged(tag: Int){
        switch tag {
        case 0:
            todayButton.pulsate()
            todayButton.titleLabel?.font = .avenir20()
            todayButton.setTitleColor(.white, for: .normal)
            
            lastweekButton.titleLabel?.font = .avenir18()
            lastweekButton.setTitleColor(.myCyan(), for: .normal)
            
            lastmonthButton.titleLabel?.font = .avenir18()
            lastmonthButton.setTitleColor(.myCyan(), for: .normal)
            time = "day"
            
            getAnsweredQuestions()
        case 1:
            lastweekButton.pulsate()
            lastweekButton.titleLabel?.font = .avenir20()
            lastweekButton.setTitleColor(.white, for: .normal)
            
            todayButton.titleLabel?.font = .avenir18()
            todayButton.setTitleColor(.myCyan(), for: .normal)
            
            lastmonthButton.titleLabel?.font = .avenir18()
            lastmonthButton.setTitleColor(.myCyan(), for: .normal)
            time = "week"
            
            getAnsweredQuestions()
        case 2:
            lastmonthButton.pulsate()
            lastmonthButton.titleLabel?.font = .avenir20()
            lastmonthButton.setTitleColor(.white, for: .normal)
            
            todayButton.titleLabel?.font = .avenir18()
            todayButton.setTitleColor(.myCyan(), for: .normal)
            
            lastweekButton.titleLabel?.font = .avenir18()
            lastweekButton.setTitleColor(.myCyan(), for: .normal)
            time = "month"
            getAnsweredQuestions()
            
        default:
            break
        }
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func showUI(){
        tableView.isHidden = false
        mydataButton.isHidden = false
        alldataButton.isHidden = false
        todayButton.isHidden = false
        lastweekButton.isHidden = false
        lastmonthButton.isHidden = false
        slideView.isHidden = false
        roomLocationLabel.isHidden = false
        label.isHidden = true
    }
    func hideUI(){
        tableView.isHidden = true
        mydataButton.isHidden = true
        alldataButton.isHidden = true
        todayButton.isHidden = true
        lastweekButton.isHidden = true
        lastmonthButton.isHidden = true
        slideView.isHidden = true
        roomLocationLabel.isHidden = true
        label.isHidden = false
    
        
    }
    
    func animateSlideGesture(right: Bool){
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
extension DataTabController: ManuallyChangedRoom {
    func roomchanged(roomname: String, roomid: String) {
        manuallyChangedRoom = true
        choosenRoom = roomname
        choosenRoomId = roomid
        choosenRoomLabel.text = "showing questions answered from \(roomname)"
        getAnsweredQuestions()
    }
}
extension DataTabController: UserChangedRoomDelegate {
    func userChangedRoom(roomname: String, roomid: String) {
        currentRoom = roomname
        currentRoomId = roomid
        roomLocationLabel.text = "You are in \(roomname) 🙂"
        
        if !manuallyChangedRoom {
            choosenRoom = roomname
            choosenRoomId = roomid
            choosenRoomLabel.text =  "showing questions answered from \(roomname)"
            getAnsweredQuestions()
        }
    }
}
