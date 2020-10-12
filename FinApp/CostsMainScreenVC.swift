//
//  CostsMainScreenVC.swift
//  FinApp
//
//  Created by Alexey on 12.10.2020.
//

import UIKit
import RealmSwift

// #MARK: Realm Models

class Category: Object {
    
    @objc dynamic var name = String()
    
}

class Cost: Object {
    
    @objc dynamic var name = String()
    @objc dynamic var date = Date()
    @objc dynamic var summ = Int()
    @objc dynamic var category = String()
    
        
}

// #MARK: ViewController

class CostsMainScreenVC: UIViewController {

    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var shadowLockView: UIView!
    
    // #MARK: - Base Variables
    private let realm = try! Realm()
    var categoryList: [Category] = []
    var isTapped = false
    var selectedRow = Int()

    
    enum WindowState {
        case editing
        case normal
    }
    
    // #MARK: - Change state func
    func changeState(withState state: WindowState) {
        switch state {
        case .editing:
            categoryTextField.isHidden = false
            shadowLockView.isHidden = false
        case .normal:
            categoryTextField.isHidden = true
            shadowLockView.isHidden = true
        }
    }
    
    // #MARK: - Base Settings
    func baseSettings() {
        addCategoryButton.layer.cornerRadius = 20
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        
        
    }
    
    // #MARK: - Save Category func
    func saveCategory(withName name: String) {
        let category = Category()
        try! realm.write {
            category.name = name
            realm.add(category)
            categoryList.insert(category, at: 0)
        }
        categoryTableView.reloadData()
    }
    
    // #MARK: - Remove Category func
    func removeCategory(withCategory category: Category){
        
        try! realm.write {
            realm.delete(category)
        }
        
    }
    
    
    // #MARK: - Load data from Chache
    func loadFromChache() {
        categoryList = realm.objects(Category.self).map {$0}
    }
    
    // #MARK: - Category Button Action
    @IBAction func addCategoryButtonAction(_ sender: Any) {
        
        if categoryTextField.isHidden {
            changeState(withState: .editing)
            categoryTextField.becomeFirstResponder()
        } else {
            if categoryTextField.text == "" {
                changeState(withState: .normal)
                categoryTextField.resignFirstResponder()
            }else {
                categoryTextField.resignFirstResponder()
                let categoryName = categoryTextField.text
                saveCategory(withName: categoryName!)
                changeState(withState: .normal)
                categoryTextField.text = ""
            }
        }
        
    }
    
    // MARK: Keyboard functions
    
    func registerForKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CostsMainScreenVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CostsMainScreenVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    // #MARK: - Deinit method
    deinit {
        removeKeyboardNotifications()
    }
    
    // #MARK: - ViewDidLoad func
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSettings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        registerForKeyBoardNotifications()
        loadFromChache()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    // #MARK: - Segue func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailCostVC {
            let categoryName = categoryList[selectedRow].name
            destination.categoryName = categoryName
        }
    }
    

}

// #MARK: TableView extension

extension CostsMainScreenVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
        let category = categoryList[indexPath.row]
        cell.categoryLabel.text = category.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = categoryList[indexPath.row]
            categoryList.remove(at: indexPath.row)
            categoryTableView.deleteRows(at: [indexPath], with: .bottom)
            removeCategory(withCategory: category)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "detailCost", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}
