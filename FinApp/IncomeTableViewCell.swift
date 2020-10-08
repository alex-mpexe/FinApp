//
//  IncomeTableViewCell.swift
//  FinApp
//
//  Created by Alexey on 07.10.2020.
//

import UIKit

class IncomeTableViewCell: UITableViewCell {

    @IBOutlet weak var incomeTableLabel: UILabel!
    
    @IBOutlet weak var dateTableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
