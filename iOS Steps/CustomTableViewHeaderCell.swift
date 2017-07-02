//
//  CustomTableViewHeaderCell.swift
//  HealthKit-Test
//
//  Created by Steve on 28/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit

class CustomTableViewHeaderCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
