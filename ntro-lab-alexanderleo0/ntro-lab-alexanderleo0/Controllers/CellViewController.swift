//
//  CellViewController.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 03.02.2023.
//

import Foundation
import UIKit

class CellViewController: UITableViewCell {
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsReadCounter: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
