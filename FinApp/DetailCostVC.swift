//
//  DetailCostVC.swift
//  FinApp
//
//  Created by Alexey on 12.10.2020.
//

import UIKit

class DetailCostVC: UIViewController {


    var categoryName = String()
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLabel.text = categoryName
    }
    

}
