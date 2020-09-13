//
//  ListSectionHeader.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/9/11.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit

protocol ListSectionHeaderDelegate: class {
    func onCollapseButtonPressed(sender: UIButton)
    func onAddButtonPressed(sender: UIButton)
}

class ListSectionHeader: UITableViewHeaderFooterView {
    
    var delegate: ListSectionHeaderDelegate?
    let collapseButton = UIButton()
    let addButton = UIButton()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        collapseButton.contentHorizontalAlignment = .left
        addButton.contentHorizontalAlignment = .center
        
        collapseButton.setTitleColor(.white, for: .normal)

        let plusSymbol = UIImage(systemName: "plus.circle.fill",
              withConfiguration: UIImage.SymbolConfiguration(pointSize: 22))
        addButton.setImage(plusSymbol, for: .normal)
        addButton.tintColor = .white
        
        contentView.backgroundColor = K.themeColor
        contentView.addSubview(collapseButton)
        contentView.addSubview(addButton)
        
        let failurePoint = addButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        failurePoint.priority = UILayoutPriority(rawValue: 999)

        NSLayoutConstraint.activate([
            
            collapseButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            collapseButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            collapseButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collapseButton.trailingAnchor.constraint(equalTo:     addButton.leadingAnchor),

            failurePoint,
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 40)
            
        ])
        
        collapseButton.addTarget(self, action: #selector(onCollapseButtonPressed(sender:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(onAddButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc func onCollapseButtonPressed(sender: UIButton) {
        delegate?.onCollapseButtonPressed(sender: sender)
    }
    
    @objc func onAddButtonPressed(sender: UIButton) {
        delegate?.onAddButtonPressed(sender: sender)
    }
}

