//
//  AdminOrgCell.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit
protocol AdminOrgCellDelegate{
    func removePushed(cell:AdminOrgCell)
}

class AdminOrgCell: UITableViewCell {

    var delegate:AdminOrgCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var orgID:Int?
    
    @IBAction func removePushed(_ sender: UIButton) {
//        print("You pushed remove")
        delegate!.removePushed(cell:self)
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
