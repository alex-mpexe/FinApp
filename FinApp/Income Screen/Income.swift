//
//  Income.swift
//  FinApp
//
//  Created by Alexey on 07.10.2020.
//

import Foundation
import RealmSwift

class Income: Object {
    
    @objc dynamic var amount = String()
    @objc dynamic var date = String()

}
