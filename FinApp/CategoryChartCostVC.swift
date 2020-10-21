//
//  CategoryChartCostVC.swift
//  FinApp
//
//  Created by Alexey on 20.10.2020.
//

import UIKit
import Charts
import RealmSwift

class CategoryChartCostVC: UIViewController, ChartViewDelegate {
    
    // #MARK: IBOutlets
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var quarterButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
    // #MARK: IBActions
    @IBAction func weekButtonPressed(_ sender: Any) {
        createPoints(costData: costsRealmData!)
        var newPoints: [Point] = []
        var firstDayOfWeek = calendar.date(byAdding: .weekOfMonth, value: -1, to: today)!
        while firstDayOfWeek <= today {
            let filteredPoints = updatePoints(date: parseDate(withDate: firstDayOfWeek))
            if filteredPoints.count != 0 { newPoints += filteredPoints }
            firstDayOfWeek = calendar.date(byAdding: .day, value: 1, to: firstDayOfWeek)!
        }
        chartPoints = newPoints
        updateChart()
        self.lineChartView.notifyDataSetChanged()
        changeButtonState(type: .week)
    }
    @IBAction func monthButtonPressed(_ sender: Any) {
        createPoints(costData: costsRealmData!)
        var newPoints: [Point] = []
        var lastMonthDay = calendar.date(byAdding: .month, value: -1, to: today)!
        while lastMonthDay <= today {
            let filteredPoints = updatePoints(date: parseDate(withDate: lastMonthDay))
            if filteredPoints.count != 0 { newPoints += filteredPoints }
            lastMonthDay = calendar.date(byAdding: .day, value: 1, to: lastMonthDay)!
        }
        chartPoints = newPoints
        updateChart()
        self.lineChartView.notifyDataSetChanged()
        changeButtonState(type: .month)
    }
    @IBAction func quarterButtonPressed(_ sender: Any) {
        createPoints(costData: costsRealmData!)
        var newPoints: [Point] = []
        var lastMonthDay = calendar.date(byAdding: .month, value: -2, to: today)!
        while lastMonthDay <= today {
            let filteredPoints = updatePoints(date: parseDate(withDate: lastMonthDay))
            if filteredPoints.count != 0 { newPoints += filteredPoints }
            lastMonthDay = calendar.date(byAdding: .day, value: 1, to: lastMonthDay)!
        }
        chartPoints = newPoints
        updateChart()
        self.lineChartView.notifyDataSetChanged()
        changeButtonState(type: .quarter)
    }
    @IBAction func allDatesButtonPressed(_ sender: Any) {
        createPoints(costData: costsRealmData!)
        updateChart()
        self.lineChartView.notifyDataSetChanged()
        changeButtonState(type: .all)
    }
    
    // #MARK: Base variables
    enum SortType {
        case week
        case month
        case quarter
        case all
    }
    private let realm = try! Realm()
    var costsRealmData: Results<Cost>? {didSet {createPoints(costData: costsRealmData!)}}
    var chartPoints: [Point] = [] {
        didSet {
            lineChartView.xAxis.valueFormatter = ChartDataFormatter(dataPoints: chartPoints.map {$0.date!})
        }
    }
    let calendar = Calendar.current
    let today = Date()
    var category = String()
    
    // #MARK: Base settings for the app
    func baseSettings() {
        weekButton.layer.cornerRadius = 12
        monthButton.layer.cornerRadius = 12
        quarterButton.layer.cornerRadius = 12
        allButton.layer.cornerRadius = 12
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        changeButtonState(type: .all)
//        lineChartView.xAxis.valueFormatter = ChartDataFormatter(dataPoints: chartPoints.map {$0.date!})
        
    }
    
    // #MARK: Changing button states
    func changeButtonState(type: SortType){
        switch type {
        case .week:
            allButton.isEnabled = true
            allButton.backgroundColor = .systemBlue
            weekButton.isEnabled = false
            weekButton.backgroundColor = .gray
            monthButton.isEnabled = true
            monthButton.backgroundColor = .systemBlue
            quarterButton.isEnabled = true
            quarterButton.backgroundColor = .systemBlue
        case .month:
            allButton.isEnabled = true
            allButton.backgroundColor = .systemBlue
            weekButton.isEnabled = true
            weekButton.backgroundColor = .systemBlue
            monthButton.isEnabled = false
            monthButton.backgroundColor = .gray
            quarterButton.isEnabled = true
            quarterButton.backgroundColor = .systemBlue
        case .quarter:
            allButton.isEnabled = true
            allButton.backgroundColor = .systemBlue
            weekButton.isEnabled = true
            weekButton.backgroundColor = .systemBlue
            monthButton.isEnabled = true
            monthButton.backgroundColor = .systemBlue
            quarterButton.isEnabled = false
            quarterButton.backgroundColor = .gray
        case .all:
            allButton.isEnabled = false
            allButton.backgroundColor = .gray
            weekButton.isEnabled = true
            weekButton.backgroundColor = .systemBlue
            monthButton.isEnabled = true
            monthButton.backgroundColor = .systemBlue
            quarterButton.isEnabled = true
            quarterButton.backgroundColor = .systemBlue
        }
    }
    
    // MARK: Parse Date Func
        func parseDate(withDate date: Date?) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "dd.MM"
            let stringDate = "\(formatter.string(from: date!))"
            return stringDate
        }
    
    // #MARK: Creating points
    func createPoints(costData: Results<Cost>){
        var points: [Point] = []
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
    
    // #MARK: Update Points
        func updatePoints(date: String) -> [Point] {
            var points: [Point] = []
            for point in chartPoints {
                if point.date == date {
                    points.append(point)
                }
            }
            return points
        }
    
    // #MARK: Update Charts data
        func updateChart() {
            var costDataEntry: [ChartDataEntry] = []
            
            for (index, point) in chartPoints.enumerated() {
                let entry = ChartDataEntry(x: Double(index), y: Double(point.moneySumm!))
                costDataEntry.append(entry)
            }
            let chartData = LineChartData()
            let costLine = LineChartDataSet(entries: costDataEntry, label: "Расходы")
            costLine.setColor(.red)
            costLine.circleColors = [UIColor(ciColor: .red)]
            chartData.addDataSet(costLine)
            
            self.lineChartView.data = chartData
            
        }
    
    // #MARK: Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSettings()
        costsRealmData = realm.objects(Cost.self).filter("category = '\(category)'")
        self.lineChartView.delegate = self
        updateChart()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        costsRealmData = realm.objects(Cost.self).filter("category = '\(category)'")
        updateChart()
    }

}
