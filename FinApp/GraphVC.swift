//
//  GraphVC.swift
//  FinApp
//
//  Created by Alexey on 14.10.2020.
//

import UIKit
import Charts
import RealmSwift

private class ChartDataFormatter: IAxisValueFormatter {
    
    var data: [String] = []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return data[Int(value)]
    }
    
    init(dataPoints: [String]) {
        self.data = dataPoints
    }
}

class Point {
    
    enum PointType {
        case income
        case cost
    }
    
    var moneySumm: Int?
    var date: String?
    var rawDate: Date?
    var pointType: PointType?
    
    init(moneySumm: Int, date: String, type: PointType){
        self.moneySumm = moneySumm
        self.date = date
        self.pointType = type
    }
    
    func prepareIncomeDate(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        let incomeDate = formatter.date(from: self.date!)
        self.rawDate = incomeDate
        formatter.dateFormat = "dd.MM"
        let correctDate = formatter.string(from: incomeDate!)
        self.date = correctDate
    }
    
    func prepareCostDate(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        let incomeDate = formatter.date(from: self.date!)
        self.rawDate = incomeDate
        formatter.dateFormat = "dd.MM"
        let correctDate = formatter.string(from: incomeDate!)
        self.date = correctDate
    }
}

class GraphVC: UIViewController, ChartViewDelegate {

// #MARK: Base variables
    private let realm = try! Realm()
    enum PointType {
        case income
        case cost
    }
    
    var incomeRealmData: Results<Income>?
    var costsRealmData: Results<Cost>? {didSet {createPoints(incomeData: incomeRealmData!, costData: costsRealmData!)}}
    var chartPoints: [Point] = [] {
        didSet {
            lineChartView.xAxis.valueFormatter = ChartDataFormatter(dataPoints: chartPoints.map {$0.date!})
        }
    }
    var chartEntryDataSet: [ChartDataEntry] = []
    
    
// #MARK: Outlets
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var quarterButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
// #MARK: Sort button actions
    @IBAction func weekButtonPressed(_ sender: Any) {
    }
    @IBAction func monthButtonPressed(_ sender: Any) {
    }
    @IBAction func quarterButtonPressed(_ sender: Any) {
    }
    @IBAction func allDatesButtonPressed(_ sender: Any) {
    }
    
    
    
    
// #MARK: Base settings method
    func baseSettings() {
        weekButton.layer.cornerRadius = 12
        monthButton.layer.cornerRadius = 12
        quarterButton.layer.cornerRadius = 12
        allButton.layer.cornerRadius = 12
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.valueFormatter = ChartDataFormatter(dataPoints: chartPoints.map {$0.date!})
        
        
    }
    
// #MARK: Loading data from chache
    func loadDataFromCache() {
        incomeRealmData = realm.objects(Income.self)
        costsRealmData = realm.objects(Cost.self)
    }
    
// #MARK: Creating ChartPoint list
    func createPoints(incomeData: Results<Income>, costData: Results<Cost>) {
        var points: [Point] = []
        
        // income data
        let incomeDates = Set(incomeData.map {$0.date})
        for date in incomeDates {
            var moneySumm = 0
            let incomeFromDate = realm.objects(Income.self).filter("date = '\(date)'").map {$0}
            if incomeFromDate.count != 0 {
                for income in incomeFromDate { moneySumm += Int(income.amount)! }
                let incomePoint = Point(moneySumm: moneySumm, date: date, type: .income)
                incomePoint.prepareIncomeDate()
                points.append(incomePoint)
            }
        }
        
        // cost data
        let costDates = Set(costData.map {$0.date})
        for date in costDates {
            let costFromDate = costData.filter("date = '\(date)'").map {$0}
            if costFromDate.count != 0 {
                var moneySumm = 0
                for cost in costFromDate {
                    moneySumm += cost.summ
                }
                let costPoint = Point(moneySumm: moneySumm, date: date, type: .cost)
                costPoint.prepareCostDate()
                points.append(costPoint)
            }
        }
    
        chartPoints = points.sorted(by: {
                    let date1 = $0.rawDate!
                    let date2 = $1.rawDate!
                    return date1.compare(date2) == .orderedAscending
        })
    }
 
// #MARK: Update Charts data
    
    func updateChart() {
        var costDataEntry: [ChartDataEntry] = []
        var incomeDataEntry: [ChartDataEntry] = []
        
        for (index, point) in chartPoints.enumerated() {
            switch point.pointType {
            case .cost:
                let entry = ChartDataEntry(x: Double(index), y: Double(point.moneySumm!))
                costDataEntry.append(entry)
    
            case .income:
                let entry = ChartDataEntry(x: Double(index), y: Double(point.moneySumm!))
                incomeDataEntry.append(entry)
            case .none:
                return
            }
        }
        let chartData = LineChartData()
        let incomeLine = LineChartDataSet(entries: incomeDataEntry, label: "Расходы")
        incomeLine.setColor(.green)
        incomeLine.circleColors = [UIColor(ciColor: .green)]
        chartData.addDataSet(incomeLine)
        let costLine = LineChartDataSet(entries: costDataEntry, label: "Доходы")
        costLine.setColor(.red)
        costLine.circleColors = [UIColor(ciColor: .red)]
        chartData.addDataSet(costLine)
        
        self.lineChartView.data = chartData
        
    }
    
// MARK: Parse Date Func
    func parseDate(withDate date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM"
        let stringDate = "\(formatter.string(from: date!))"
        return stringDate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSettings()
        loadDataFromCache()
        self.lineChartView.delegate = self
        updateChart()
        self.lineChartView.notifyDataSetChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        loadDataFromCache()
        updateChart()
    }


}
