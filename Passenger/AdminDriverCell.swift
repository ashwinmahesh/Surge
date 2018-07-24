//
//  AdminDriverCell.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
protocol AdminDriverCellDelegate{
    func removePushed(cell: AdminDriverCell)
}

class AdminDriverCell: UITableViewCell {
    
    var delegate:AdminDriverCellDelegate!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBAction func removePushed(_ sender: UIButton) {
        delegate.removePushed(cell: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
