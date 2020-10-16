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

class ChartPoint {
    var summ = Int()
    var dateString = String()
    var date = Date()
    
    init(summ: Int, dateString: String) {
        let truncDate = dateString.split(separator: ".")
        self.dateString = "\(truncDate[0]).\(truncDate[1])"
        self.summ = summ
        self.date = self.fromStringToDate(stringDate: dateString)
    }
    
    func fromStringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        if let date = dateFormatter.date(from: stringDate) {
            return date
        } else {return Date()}
    }
}

class GraphVC: UIViewController {

    
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
    
    // #MARK: Base variables
    private let realm = try! Realm()
    
    var costRealmData: [Cost] = [] {
        didSet { createCostPoint(withData: costRealmData) }
    }
    var incomeRealmData: [Income] = []
    var chartCostPoints: [ChartPoint] = [] {
        didSet { lineChartView.xAxis.valueFormatter = ChartDataFormatter(dataPoints: chartCostPoints.map {$0.dateString}) }
    }
    var chartIncomePoints: [ChartPoint] = []
    
    var costEntryDataSet: [ChartDataEntry] = []
    var costDataSet = LineChartDataSet()
    var costData = LineChartData()
    
    enum DateRange {
        case week
        case month
        case quarter
        case all
    }
    
    enum PointType {
        case cost
        case income
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
        lineChartView.xAxis.valueFormatter = ChartDataFormatter(dataPoints: chartCostPoints.map {$0.dateString})
        
        
    }
    
    // #MARK: Loading data from chache
    func loadDataFromChache() {
        costRealmData = realm.objects(Cost.self).map {$0}
    }
    
    // #MARK: Creating ChartPoint list
    func createCostPoint(withData data: [Cost]) {
        let dateList = Set(data.map {$0.date})
        var points: [ChartPoint] = []
        for date in dateList {
            let datePayments = realm.objects(Cost.self).filter("date = '\(date)'").map {$0.summ}
            var summ = 0
            for payment in datePayments { summ += payment }
            let point = ChartPoint(summ: summ, dateString: date)
            points.append(point)
        }
        chartCostPoints = points
        chartCostPoints = chartCostPoints.sorted(by: {
            let date1 = $0.fromStringToDate(stringDate: $0.dateString)
            let date2 = $1.fromStringToDate(stringDate: $1.dateString)
            return date1.compare(date2) == .orderedAscending
        })
    }
    
    func updateChart() {
        
        // Updating cost data
        costEntryDataSet = (0..<chartCostPoints.count).map { (i) -> ChartDataEntry in
            return ChartDataEntry(x: Double(i), y: Double(chartCostPoints[i].summ))
        }
        costDataSet = LineChartDataSet(entries: costEntryDataSet, label: "Расходы")
        costData = LineChartData(dataSet: costDataSet)
        costDataSet.setColor(.red)
        costDataSet.circleColors = [UIColor(ciColor: .red)]
        self.lineChartView.data = costData
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        costRealmData = realm.objects(Cost.self).map {$0}
        baseSettings()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        costRealmData = realm.objects(Cost.self).map {$0}
        updateChart()
    }


}
