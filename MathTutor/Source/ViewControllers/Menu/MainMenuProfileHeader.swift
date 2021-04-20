//
//  MainMenuProfileHeader.swift
//  Lightbox
//
//  Created by Jorge Castellanos on 6/12/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class MainMenuProfileHeader: UITableViewHeaderFooterView, MainMenuSectionHeaderProtocol {
    
    weak open var delegate: MainMenuSectionHeaderDelegate?
    var section: Int = 0
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = Style.Color.umcBlue
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainMenuSectionHeader.headerCellTapped(_:))))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func headerCellTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? MainMenuProfileHeader else {
            return
        }
        
        // Trigger section toggle when tapping on the header
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {

    }
    
}
