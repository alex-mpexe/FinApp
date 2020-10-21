//
//  ViewController.swift
//  FinApp
//
//  Created by Alexey on 07.10.2020.
//

import UIKit
import RealmSwift


class MainScreenViewController: UIViewController {
    
    // MARK: Basic Variables
    private let realm = try! Realm()
    var incomeData: [Income] = []
    var costData: Results<Cost>?
    var isTapped = false
    var moneySumm = 0 {
        didSet {
            currentMoneyBalance.text = "\(String(moneySumm)) Р"
            if moneySumm < 0 {
                currentMoneyBalance.textColor = UIColor.red
            } else {
                currentMoneyBalance.textColor = UIColor.white
            }
        }
    }

    // MARK: IBOutlets
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var incomeTable: UITableView!
    @IBOutlet weak var currentMoneyBalance: UILabel!
    @IBOutlet weak var summTextField: UITextField!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var shadowLockView: UIView!
    

    // MARK: Save Income Function
    func saveIncome(withSumm summ: String) {
        let income = Income()
        let date = Date()
        income.amount = summ
        income.date = parseDate(withDate: date)
        incomeData.insert(income, at: 0)
        moneySumm += Int(summ)!
        
        incomeTable.reloadData()
        
        try! realm.write {
            realm.add(income)
        }
    }
    
    // MARK: Parse Date method
    func parseDate(withDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        
        let stringDate = "\(formatter.string(from: date))"
        
        return stringDate
    }
    
    // MARK: Change state method
    func changeState() {
        summTextField.isHidden = !summTextField.isHidden
        shadowLockView.isHidden = !shadowLockView.isHidden
    }
    
    // MARK: Add Income Button function
    @IBAction func addIncomeAction(_ sender: Any) {
        if summTextField.isHidden {
            changeState()
            summTextField.becomeFirstResponder()
        } else {
            if summTextField.text == "" {
                changeState()
                summTextField.resignFirstResponder()
            }else {
                summTextField.resignFirstResponder()
                
                let newSumm = summTextField.text
                saveIncome(withSumm: newSumm!)
                changeState()
                summTextField.text = ""
            }
        }
    }
    
    // MARK: Update Money Summ
    func updateMoneySumm () {
        let incomeSummList = realm.objects(Income.self).map {$0.amount}
        let costsSummList = realm.objects(Cost.self).map {$0.summ}
        var costsSumm = 0
        var incomeSumm = 0
        if incomeSummList.count != 0{
            for income in incomeSummList { incomeSumm += Int(income)! }
        }
        if costsSummList.count != 0 {
            for cost in costsSummList { costsSumm += cost }
        }
        moneySumm = incomeSumm - costsSumm
    }
    
    
    // MARK: Base Settings
    func baseSettings() {
        addIncomeButton.layer.cornerRadius = 20
        incomeTable.delegate = self
        incomeTable.dataSource = self
        currentMoneyBalance.text = "\(String(moneySumm)) Р"
    }
    
    // MARK: Loading data from cache
    func loadFromCache() {
        incomeData = realm.objects(Income.self).map {$0}
        costData = realm.objects(Cost.self)
    }
    
    // MARK: ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSettings()
        loadFromCache()
        updateMoneySumm()
        addTapGestureToHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        loadFromCache()
        updateMoneySumm()
        registerForKeyBoardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    

    // MARK: Keyboard methods
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func registerForKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MainScreenViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainScreenViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGesture() {
        summTextField.resignFirstResponder()
        isTapped = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let window = self.view.window?.frame
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window!.origin.y + window!.height - keyboardSize.height + 50)
        } else {}
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height - 50)
        } else {}
    }
    

}

// MARK: Extention for Table View

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = incomeTable.dequeueReusableCell(withIdentifier: "incomeCell", for: indexPath) as! IncomeTableViewCell
        
        cell.incomeTableLabel.text = "+ \(incomeData[indexPath.row].amount) Р"
        cell.dateTableLabel.text = "\(incomeData[indexPath.row].date)г."
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
}
