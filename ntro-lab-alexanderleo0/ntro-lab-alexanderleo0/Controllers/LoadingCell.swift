//
//  LoadingCell.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 21.02.2023.
//

import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet weak var activityContoller: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
