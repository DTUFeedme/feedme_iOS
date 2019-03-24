//
//  DiagramViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 24/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import Charts

class DiagramViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    var dummyDataEntry1 = PieChartDataEntry(value: 10)
    var dummyDataEntry2 = PieChartDataEntry(value: 17)
 
    var dataEntries = [PieChartDataEntry]()
    
    @IBAction func tapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 15
        bgView.layer.masksToBounds = true
        pieChart.holeColor = UIColor.clear
        
        dummyDataEntry1.label = "Too Warm"
        dummyDataEntry2.label = "Too Cold"
        
        
        dataEntries = [dummyDataEntry1,dummyDataEntry2]
        updateChart()

    }
    
    func updateChart(){
        let chartDataSet = PieChartDataSet(values: dataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        chartDataSet.colors = [Colors.cyan,.darkGray]
        
        pieChart.data = chartData
    }
    
    
    
}
