//
//  ItemCell.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/30.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

protocol ItemCellDelegate: class {
    func addItem(_ newTitle: String)
    func deleteItem(at index: Int)
    func saveDataAndReloadTable()
}

class ItemCell: UITableViewCell {
    
    var item: Item?
    var index = -1
    weak var delegate: ItemCellDelegate?

        
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
        
        if sender.text == "" {
            if index > 0 {
                delegate?.deleteItem(at: index)
            }
        } else {
            if index == 0 {
                //add new item
                delegate?.addItem(sender.text!)
            } else {
                //put edited item first
                delegate?.deleteItem(at: index)
                delegate?.addItem(sender.text!)
            }
        }
        delegate?.saveDataAndReloadTable()
    }
    
    
    func updateCheckmark(_ done: Bool) {
        
        checkMark.image = done ? K.checkedSymbol: K.uncheckedSymbol
    }
    
//    func setDoneState(_ checked: Bool) {
//        
//        item?.done = checked
//        checkMark.image = checked ? K.checkedSymbol: K.uncheckedSymbol
//    }
    
}

