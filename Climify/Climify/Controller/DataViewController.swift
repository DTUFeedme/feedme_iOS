import UIKit
import Charts

class DataViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
//    @IBOutlet weak var pieChart: PieChartView!
//
//
//    var iosDataEntry = PieChartDataEntry(value: 0)
//    var macDataEntry = PieChartDataEntry(value: 0)
//
//
    
    var months: [Int]!
    //var numberOfDownloadsDataEntries = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.noDataText = "You need to provide data for the chart."
        
        months = [1,2,3]
        let unitsSold = [20, 4, 6]
        
        setChart(dataPoints: months, values: unitsSold)
        
//        pieChart.chartDescription?.text = ""
//        iosDataEntry.label = "Too hot"
//        macDataEntry.label = "Too cold"
//
//        pieChart.holeColor = UIColor.clear
//        numberOfDownloadsDataEntries = [iosDataEntry, macDataEntry]
//
//        iosDataEntry.value = 10
//        macDataEntry.value = 13
//
//        updateChartData()
        
    }
    
   
    
    func setChart(dataPoints: [Int], values: [Int]) {
        
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]) )
            dataEntries.append(dataEntry)
            
        }
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .top
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter(chart: barChartView)

        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"

        let leftAxis = barChartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        
        
//        let marker = MarkerView(color: UIColor(white: 0.35, alpha: 1))
//        marker.chartView = barChartView
//        marker.minimumSize = CGSize(width: 80, height: 40)
//        barChartView.marker = marker
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
        let chartData = BarChartData(dataSet: chartDataSet)
         barChartView.data = chartData
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}


public class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let days = Int(value)
        let year = determineYear(forDays: days)
        let month = determineMonth(forDayOfYear: days)
        
        let monthName = months[month % months.count]
        let yearName = "\(year)"
        
        if let chart = chart,
            chart.visibleXRange > 30 * 6 {
            return monthName + yearName
        } else {
            let dayOfMonth = determineDayOfMonth(forDays: days, month: month + 12 * (year - 2016))
            var appendix: String
            
            switch dayOfMonth {
            case 1, 21, 31: appendix = "st"
            case 2, 22: appendix = "nd"
            case 3, 23: appendix = "rd"
            default: appendix = "th"
            }
            
            return dayOfMonth == 0 ? "" : String(format: "%d\(appendix) \(monthName)", dayOfMonth)
        }
    }
    
    private func days(forMonth month: Int, year: Int) -> Int {
        // month is 0-based
        switch month {
        case 1:
            var is29Feb = false
            if year < 1582 {
                is29Feb = (year < 1 ? year + 1 : year) % 4 == 0
            } else if year > 1582 {
                is29Feb = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
            }
            
            return is29Feb ? 29 : 28
            
        case 3, 5, 8, 10:
            return 30
            
        default:
            return 31
        }
    }
    
    private func determineMonth(forDayOfYear dayOfYear: Int) -> Int {
        var month = -1
        var days = 0
        
        while days < dayOfYear {
            month += 1
            if month >= 12 {
                month = 0
            }
            
            let year = determineYear(forDays: days)
            days += self.days(forMonth: month, year: year)
        }
        
        return max(month, 0)
    }
    
    private func determineDayOfMonth(forDays days: Int, month: Int) -> Int {
        var count = 0
        var daysForMonth = 0
        
        while count < month {
            let year = determineYear(forDays: days)
            daysForMonth += self.days(forMonth: count % 12, year: year)
            count += 1
        }
        
        return days - daysForMonth
    }
    
    private func determineYear(forDays days: Int) -> Int {
        switch days {
        case ...366: return 2016
        case 367...730: return 2017
        case 731...1094: return 2018
        case 1095...1458: return 2019
        default: return 2020
        }
    }
}
