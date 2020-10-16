//
//  GraphView.swift
//  FinApp
//
//  Created by Alexey on 14.10.2020.
//

import UIKit
import RealmSwift

class Point {
    var summ = String()
    var date = String()
    
    init(summ: String, date: String) {
        self.summ = summ
        self.date = date
    }
    
    func drawPoint(dateLabel: UILabel, summLabel: UILabel, viewToDraw: UIView) {
        let pointView = UIView(frame: CGRect(x: 0, y: 50, width: 10, height: 10))
        pointView.backgroundColor = .red
        pointView.alpha = 0.5
        pointView.layer.cornerRadius = 5
        
        viewToDraw.addSubview(pointView)
       
        
    }
    
}

class GraphView: UIView {

    private let backgroundView = UIView()
    private let dateStackView = UIStackView()
    private let summStackView = UIStackView()

    
    private let realm = try! Realm()
    var paymentData: [Cost] = []
    var paymentPoints: [Point] = []
    var isSetuped = false
    
    enum DateRange {
        case week
        case month
        case quarter
    }
    
    func loadDataFromChache() {
        paymentData = realm.objects(Cost.self).map {$0}
        createPoint(withData: paymentData)
    }
    
    func createPoint(withData data: [Cost]) {
        let dateList = Set(data.map {$0.date})
        for date in dateList {
            let datePayments = realm.objects(Cost.self).filter("date = '\(date)'").map {$0.summ}
            var summ = 0
            for payment in datePayments { summ += payment }
            let point = Point(summ: String(summ), date: date)
            paymentPoints.append(point)
        }
        
    }
    
    func fromStringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let date = dateFormatter.date(from: stringDate) {
            return date
        } else {return Date()}
    }
    
    func truncateDate(date: String) -> String {
        let truncDate = date.split(separator: ".")
        let editedDate = "\(truncDate[0]).\(truncDate[1])"
        return editedDate
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        loadDataFromChache()
        addSubview(backgroundView)
        let mainViewWidth = frame.size.width
        let mainViewHeight = frame.size.height
        let constantMargin: CGFloat = 20
        
        
// #MARK: Background View Settings
        backgroundView.frame = CGRect(x: constantMargin, y: constantMargin, width: mainViewWidth - constantMargin * 2, height: mainViewHeight - constantMargin * 2)
        backgroundView.addSubview(dateStackView)
        backgroundView.addSubview(summStackView)
        backgroundView.backgroundColor = .white
    
// #MARK: Summ StackView settings
        summStackView.frame = CGRect(x: 0, y: 0, width: 50, height: backgroundView.frame.size.height - constantMargin)
        summStackView.distribution = .equalSpacing
        summStackView.axis = .vertical
        summStackView.alignment = .fill
        summStackView.spacing = 50
        
// #MARK: Date StackView settings
        dateStackView.frame = CGRect(x: summStackView.frame.size.width, y: backgroundView.frame.size.height - constantMargin, width: backgroundView.frame.size.width - constantMargin * 2, height: 30)
        dateStackView.distribution = .equalSpacing
        dateStackView.axis = .horizontal
        dateStackView.alignment = .fill
        dateStackView.spacing = 50
        for point in paymentPoints {
            let dateLabel = UILabel()
            dateLabel.text = truncateDate(date: point.date)
            dateLabel.textColor = .black
            dateLabel.font = dateLabel.font.withSize(10)
            let summLabel = UILabel()
            summLabel.textColor = .black
            summLabel.font = dateLabel.font.withSize(10)
            summLabel.text = point.summ
            point.drawPoint(dateLabel: dateLabel, summLabel: summLabel, viewToDraw: backgroundView)
            dateStackView.addArrangedSubview(dateLabel)
            dateStackView.setCustomSpacing(20, after: dateLabel)
            summStackView.addArrangedSubview(summLabel)
            
            print(dateLabel.frame.origin)
            print(dateLabel.convert(dateLabel.frame, to: backgroundView))
        }
        

        
        
        if isSetuped {return}
        isSetuped = true
    }

}
