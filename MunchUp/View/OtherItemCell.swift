//
//  OtherItemCell.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/30.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class OtherItemCell: UITableViewCell {

    var item: OtherItem?
    
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func titleTextFieldEditingDidBegin(_ sender: UITextField) {
        sender.borderStyle = .roundedRect
    }
    
    @IBAction func titleTextFieldEditingDidEnd(_ sender: UITextField) {
        sender.borderStyle = .none
    }
    
    
//    func setDoneState(_ checked: Bool) {
//        
//        item?.done = checked
//        checkMark.image = checked ? K.checkedSymbol: K.uncheckedSymbol
//    }
    
}

