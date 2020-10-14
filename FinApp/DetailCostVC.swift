//
//  DetailCostVC.swift
//  FinApp
//
//  Created by Alexey on 12.10.2020.
//

import UIKit
import RealmSwift

// #MARK: Realm Models
class Cost: Object {
    
    @objc dynamic var name = String()
    @objc dynamic var date = String()
    @objc dynamic var summ = Int()
    @objc dynamic var category = String()
    
}

class DetailCostVC: UIViewController {

// #MARK: Outlets
    
    @IBOutlet weak var paymentGraphButton: UIButton!
    @IBOutlet weak var paymentTable: UITableView!
    @IBOutlet weak var plusPaymentButton: UIButton!
    @IBOutlet weak var paymentNameTextField: UITextField!
    @IBOutlet weak var paymentSummTextField: UITextField!
    @IBOutlet weak var paymentDatePicker: UIDatePicker!
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var shadowLockView: UIView!
    
// #MARK: Base variables
    
    var category = String()
    private let realm = try! Realm()
    var costList: [Cost] = []
    
    enum WindowState {
        case editing
        case normal
    }

// #MARK: IBActions
    
    @IBAction func plusPaymentButtonPressen(_ sender: Any) {
        // Plus button action
        changeState(withState: .editing)
    }
    
    @IBAction func addPaymentButtonPressen(_ sender: Any) {
        // Button "Добавить расход" action

        if paymentNameTextField.text == ""{
            changeState(withState: .normal)
        } else if paymentSummTextField.text == "" {
            changeState(withState: .normal)
        } else {
            let paymentName = paymentNameTextField.text!
            let paymentDate = parseDate(withDate: nil, datepicker: paymentDatePicker)
            let paymentSumm = paymentSummTextField.text!
            saveData(paymentName: paymentName, paymentSumm: paymentSumm, paymentDate: paymentDate)
            changeState(withState: .normal)
        }
    }
    
    @IBAction func graphPaymentButtonPressen(_ sender: Any) {
        // Button "График платежей" action
    }
    
// #MARK: Base Settings
    func baseSettings() {
        plusPaymentButton.layer.cornerRadius = 25
        paymentGraphButton.layer.cornerRadius = 20
        addPaymentButton.layer.cornerRadius = 20
        paymentNameTextField.attributedPlaceholder = NSAttributedString(string: "Наименование", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        paymentSummTextField.attributedPlaceholder = NSAttributedString(string: "Сумма", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        paymentTable.delegate = self
        paymentTable.dataSource = self
    }
    
// #MARK: Change state func
    func changeState(withState state: WindowState) {
        switch state {
        case .editing:
            paymentNameTextField.isHidden = false
            paymentSummTextField.isHidden = false
            paymentDatePicker.isHidden = false
            addPaymentButton.isHidden = false
            plusPaymentButton.isHidden = true
            shadowLockView.isHidden = false
            
            paymentNameTextField.becomeFirstResponder()
            paymentSummTextField.text = ""
            paymentNameTextField.text = ""
        case .normal:
            paymentNameTextField.isHidden = true
            paymentSummTextField.isHidden = true
            paymentDatePicker.isHidden = true
            addPaymentButton.isHidden = true
            plusPaymentButton.isHidden = false
            shadowLockView.isHidden = true
            
            paymentNameTextField.resignFirstResponder()
            paymentSummTextField.resignFirstResponder()
        }
    }
    
// MARK: Parse Date Func
    func parseDate(withDate date: Date?, datepicker: UIDatePicker?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        
        
        
        if datepicker != nil {
            let stringDate = "\(formatter.string(from: datepicker!.date))"
            return stringDate
        }
        let stringDate = "\(formatter.string(from: date!))"
        
        return stringDate
    }
    
// MARK: Load from chache
    func loadDataFromChache(){
        costList = realm.objects(Cost.self).filter("category = '\(category)'").sorted(by: {
            let date1 = fromStringToDate(stringDate: $0.date)
            let date2 = fromStringToDate(stringDate: $1.date)
            return date1.compare(date2) == .orderedDescending
        })
        
    }
    
    func fromStringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let date = dateFormatter.date(from: stringDate) {
            return date
        } else {return Date()}
    }
    
// MARK: Save data func
    func saveData(paymentName: String, paymentSumm: String, paymentDate: String){
        let cost = Cost()
        cost.name = paymentName
        cost.date = paymentDate
        cost.summ = Int(paymentSumm)!
        cost.category = category
        
        try! realm.write {
            realm.add(cost)
            costList.append(cost)
        }
        
        costList = costList.sorted(by: {
            let date1 = fromStringToDate(stringDate: $0.date)
            let date2 = fromStringToDate(stringDate: $1.date)
            return date1.compare(date2) == .orderedDescending
        })
        
        paymentTable.reloadData()
    }

// #MARK: - Remove Cost func
    func removeCost(withCost cost: Cost){
        
        try! realm.write {
            realm.delete(cost)
        }
        
    }
    
// MARK: Keyboard functions
    func registerForKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(DetailCostVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailCostVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let window = self.view.window?.frame
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window!.origin.y + window!.height - keyboardSize.height)
        } else {}
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {}
    }
    
// #MARK: Controller view func
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSettings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        registerForKeyBoardNotifications()
        loadDataFromChache()
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    

}

// #MARK: TableView methods
extension DetailCostVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = paymentTable.dequeueReusableCell(withIdentifier: "costCell") as! CostCell
        cell.costNameLabel.text = costList[indexPath.row].name
        cell.costSummLabel.text = "- \(costList[indexPath.row].summ) Р"
        cell.costDateLabel.text = costList[indexPath.row].date
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        paymentTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cost = costList[indexPath.row]
            removeCost(withCost: cost)
            costList.remove(at: indexPath.row)
            paymentTable.deleteRows(at: [indexPath], with: .bottom)
        }
    }
    
    
}
