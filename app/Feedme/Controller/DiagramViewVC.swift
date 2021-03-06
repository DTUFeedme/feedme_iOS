//
//  DiagramViewController.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 24/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import Charts

class DiagramVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var roomLocationLabel: UILabel!
    private var dataEntries = [PieChartDataEntry]()
    var feedmeNS: FeedmeNetworkService!
    
    var room = ""
    var roomID = ""
    var time = Time.day
    var question = ""
    var questionID = ""
    var meIsSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedmeNS = appDelegate.feedmeNS
        setupUI()
        fetchFeedback()
    }
    
    @IBAction func tapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupUI(){
        bgView.layer.cornerRadius = 15
        bgView.layer.masksToBounds = true
        
        roomLocationLabel.text = room
        pieChart.centerText = question
        
        let centerText = NSAttributedString(string: question, attributes: [NSAttributedString.Key.foregroundColor: UIColor.colorOne!,NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!])
        
        pieChart.centerAttributedText = centerText
        pieChart.holeColor = UIColor.clear
        let l = pieChart.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 10
        l.textColor = UIColor.colorOne!
    }
    
    private func fetchFeedback(){
        feedmeNS.fetchFeedback(questionID: questionID, roomID: roomID, time: time, me: meIsSelected, completion: {
            answers in
            for answer in answers {
                let dataEntry = PieChartDataEntry(value: Double(answer.timesAnswered))
                dataEntry.label = answer.answer.value
                self.dataEntries.append(dataEntry)
            }
            self.updateChart()
            
        }, onError: { error in
            if (FeedmeNetworkService.Connectivity.isConnectedToInternet){
                self.roomLocationLabel.text = error.errorDescription
            } else {
                self.roomLocationLabel.text = "No internet connection"
            }
        })
    }
    
    private func updateChart(){
        let chartDataSet = PieChartDataSet(values: dataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartDataSet.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]

       
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        chartData.setValueFont(.systemFont(ofSize: 14, weight: .bold))
        
        pieChart.usePercentValuesEnabled = true
        chartData.setValueTextColor(.black)
        
        pieChart.data = chartData
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
