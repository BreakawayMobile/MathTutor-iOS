//
//  MainMenuSectionHeader.swift
//  Lightbox
//
//  Created by Jorge Castellanos on 6/12/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

protocol MainMenuSectionHeaderProtocol: class {
    func setCollapsed(_ collapsed: Bool)
}

protocol MainMenuSectionHeaderDelegate: class {
    func toggleSection(_ header: MainMenuSectionHeaderProtocol, section: Int)
}

class MainMenuSectionHeader: UITableViewHeaderFooterView, MainMenuSectionHeaderProtocol {
    
    static let menuHeaderFontSize: CGFloat = 21.0
    static let menuDisclosureSize: CGFloat = 10.0

    weak open var delegate: MainMenuSectionHeaderDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let disclosureIcon = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        disclosureIcon.image = UIImage(named: "MouseDisclosureClosed")
        disclosureIcon.contentMode = .center
        
        // Constraint the size of arrow label for auto layout
        let disclosureSize = MainMenuSectionHeader.menuDisclosureSize
        disclosureIcon.widthAnchor.constraint(equalToConstant: disclosureSize).isActive = true
        disclosureIcon.heightAnchor.constraint(equalToConstant: disclosureSize).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        disclosureIcon.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.white
        titleLabel.font = Style.Font.with(family: Style.Font.Family.gothamRounded,
                                          style: Style.Font.Style.book,
                                          size: MainMenuSectionHeader.menuHeaderFontSize)

        contentView.addSubview(titleLabel)
        contentView.addSubview(disclosureIcon)
        contentView.backgroundColor = Style.Color.backgroundGray

        // Add a line at the top of each section
        contentView.addTopLine(color: Style.Color.separatorGray, height: 1.0)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(MainMenuSectionHeader.headerCellTapped(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let hiddenHeader = bounds.size.height <= 1.0
        titleLabel.isHidden = hiddenHeader
        disclosureIcon.isHidden = hiddenHeader
        
        // Autolayout the labels
        let views = ["titleLabel": titleLabel, "disclosureIcon": disclosureIcon]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-38-[titleLabel]-[disclosureIcon]-20-|",
            options: [],
            metrics: nil,
            views: views
        ))
        
        titleLabel.centerVerticallyInSuperview()
        disclosureIcon.centerVerticallyInSuperview()
    }
    
    @objc func headerCellTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? MainMenuSectionHeader else {
            return
        }
        
        // Trigger section toggle when tapping on the header
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {

        disclosureIcon.image = UIImage(named: collapsed ? "MouseDisclosureClosed" : "MouseDisclosureOpen")
    }
    
}
