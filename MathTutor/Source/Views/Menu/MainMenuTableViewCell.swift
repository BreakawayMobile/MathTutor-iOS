//
//  MainMenuTableViewCell.swift
//  Lightbox
//
//  Created by Jorge Castellanos on 6/13/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class MainMenuTableViewCell: UITableViewCell {

    static let menuFontSize: CGFloat = 16.0
    static let titleLeadingMargin: CGFloat = 70.0
    static let titleLeadingMarginNoIcon: CGFloat = 30.0

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var isSection: Bool = false
    fileprivate var isOpen: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Style.Color.umcBlue
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear

        titleLabel.textColor = UIColor.white
    }
    
    func configureWith(title: String, icon: UIImage?, isTopLevel: Bool = false) {
        self.titleLabel.text = title
        self.icon.image = icon
        
        titleLabel.font = Style.Font.with(family: Style.Font.Family.gothamRounded, style: Style.Font.Style.book, size: isTopLevel ? MainMenuSectionHeader.menuHeaderFontSize : MainMenuTableViewCell.menuFontSize)
        
        labelLeadingConstraint.constant = (icon == nil) ? MainMenuTableViewCell.titleLeadingMarginNoIcon : MainMenuTableViewCell.titleLeadingMargin
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Custom selection color
        titleLabel.textColor = selected ? Style.Color.sunflowerYellow : UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setItemLevel(_ itemLevel: Int) {        
        self.labelLeadingConstraint.constant = CGFloat(itemLevel + 1) * CGFloat(10.0)
        
        switch itemLevel {
        case 0:
            self.backgroundColor = Style.Color.menu1Blue
            break
            
        case 1:
            self.backgroundColor = Style.Color.menu2Blue
            break
            
        case 2:
            self.backgroundColor = Style.Color.menu3Blue
            break
            
        default:
            self.backgroundColor = Style.Color.menu1Blue
        }
    }
    
    func setIcon(_ isSection: Bool, isOpen: Bool) {
        if isSection == false {
            icon.image = nil
            return
        }
        
        icon.image = isOpen == true ? #imageLiteral(resourceName: "minus") : #imageLiteral(resourceName: "plus")
     }
}
