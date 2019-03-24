import UIKit
import Charts

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mydataButton: UIButton!
    @IBOutlet weak var alldataButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var lastweekButton: UIButton!
    @IBOutlet weak var lastmonthButton: UIButton!
    var questions: [String] = ["1","2"]
    let popupSegue = "popupSegue"
    var mydataIsSelected = true
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var slideView: UIView!
    
    @IBAction func alldataButtonAction(_ sender: Any) {
        if mydataIsSelected {
            animateSlideGesture()
        }
         mydataIsSelected = false
    }
    
    @IBAction func timespanAction(_ sender: UIButton) {
        updatetimeSpanUI(tag: sender.tag)
    }
    
    @IBAction func mydataButtonAction(_ sender: Any) {
        
        if !mydataIsSelected {
            animateSlideGesture()
        }
        mydataIsSelected = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellQuestion", for: indexPath) as! QuestionCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! QuestionCell
        currentCell.flash()

        self.performSegue(withIdentifier: popupSegue, sender: self)
    }
    
    
    func animateSlideGesture(){
        if mydataIsSelected {
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                            self.slideView.transform = CGAffineTransform(translationX: self.slideView.frame.size.width+2, y: 0)
            })
            tableView.transform = CGAffineTransform(translationX: tableView.frame.size.width*2, y: 0)
            alldataButton.setTitleColor(.white, for: .normal)
            mydataButton.setTitleColor(Colors.dark, for: .normal)
        } else if !mydataIsSelected {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: .curveEaseInOut,
                       animations: {
                        self.slideView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
            tableView.transform = CGAffineTransform(translationX: -tableView.frame.size.width*2, y: 0)
            alldataButton.setTitleColor(Colors.dark, for: .normal)
            mydataButton.setTitleColor(.white, for: .normal)
        }
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.tableView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        
    }
    
    func updatetimeSpanUI(tag: Int){
        switch tag {
        case 0:
            todayButton.pulsate()
            todayButton.titleLabel?.font = Fonts.avenir20
            todayButton.setTitleColor(.white, for: .normal)
            
            lastweekButton.titleLabel?.font = Fonts.avenir18
            lastweekButton.setTitleColor(Colors.cyan, for: .normal)
            
            lastmonthButton.titleLabel?.font = Fonts.avenir18
            lastmonthButton.setTitleColor(Colors.cyan, for: .normal)
            // Only for testing
            questions = ["1","2"]
        case 1:
            lastweekButton.pulsate()
            lastweekButton.titleLabel?.font = Fonts.avenir20
            lastweekButton.setTitleColor(.white, for: .normal)
            
            todayButton.titleLabel?.font = Fonts.avenir18
            todayButton.setTitleColor(Colors.cyan, for: .normal)
            
            lastmonthButton.titleLabel?.font = Fonts.avenir18
            lastmonthButton.setTitleColor(Colors.cyan, for: .normal)
            // Only for testing
            questions = ["1","1","2"]
        case 2:
            lastmonthButton.pulsate()
            lastmonthButton.titleLabel?.font = Fonts.avenir20
            lastmonthButton.setTitleColor(.white, for: .normal)
            
            todayButton.titleLabel?.font = Fonts.avenir18
            todayButton.setTitleColor(Colors.cyan, for: .normal)
            
            lastweekButton.titleLabel?.font = Fonts.avenir18
            lastweekButton.setTitleColor(Colors.cyan, for: .normal)
            
            // Only for testing
            questions = ["1","2","3","4"]
        default:
            break
        }
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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


