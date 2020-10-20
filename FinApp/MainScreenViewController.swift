//
//  ViewController.swift
//  FinApp
//
//  Created by Alexey on 07.10.2020.
//

import UIKit
import RealmSwift


class User: Object {
    @objc dynamic var moneySumm = Int()
}

class MainScreenViewController: UIViewController {
    
    var isUserCreated = false
    
    private let realm = try! Realm()
    var incomeData: [Income] = []
    
    var isTapped = false
    
    var moneySumm = 0 {
        didSet {
            currentMoneyBalance.text = "\(String(moneySumm)) Р"
            
            try! realm.write {
                let user = getUser()
                user.moneySumm = moneySumm
            }
        }
    }

    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var incomeTable: UITableView!
    @IBOutlet weak var currentMoneyBalance: UILabel!
    @IBOutlet weak var summTextField: UITextField!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var shadowLockView: UIView!
    
    func getUser() -> User{
        let user = realm.objects(User.self).map {$0}[0]
        return user
    }
    
    // MARK: User Creation
    
    func createUser(){
        let user = User()
        try! realm.write {
            realm.add(user)
            isUserCreated = true
        }
    }
    
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
    
    func parseDate(withDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        
        let stringDate = "\(formatter.string(from: date))"
        
        return stringDate
    }
    
    func changeState(){
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
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: ViewDidLoad function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isUserCreated { createUser() }
        
        incomeData = realm.objects(Income.self).map {$0}
        let user = getUser()
        moneySumm = user.moneySumm
        
        addIncomeButton.layer.cornerRadius = 20
        currentMoneyBalance.text = "\(String(moneySumm)) Р"
        
        incomeTable.delegate = self
        incomeTable.dataSource = self
        
        addTapGestureToHideKeyboard()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainScreenViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainScreenViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Keyboard functions
    
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
