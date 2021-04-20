//
//  MainMenuViewController.swift
//  Lightbox
//
//  Created by Jorge Castellanos on 6/12/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import RATreeView
import BGSMobilePackage

public class MenuBase {
    var name: String!
    var level: Int!
}

public class MenuItem: MenuBase {
    var iconName: String?
    var playlist: String?
    
    convenience init(name: String, level: Int, playlist: String, iconName: String? = nil) {
        self.init()
        
        self.name = name
        self.iconName = iconName
        self.level = level
        self.playlist = playlist
    }
}
    
//
// MARK: - Section Data Structure
//
public class Section: MenuBase {
    var items: [MenuBase] = []
    var collapsible: Bool = false
    var collapsed: Bool = true
    
    convenience init(name: String, level: Int, items: [MenuBase], collapsible: Bool = false, collapsed: Bool = true) {
        self.init()
        
        self.name = name
        self.items = items
        self.collapsible = collapsible
        self.collapsed = collapsed
        self.level = level
    }
}

class MainMenuViewController: UIViewController,
                              RATreeViewDataSource,
                              RATreeViewDelegate {

    let defaultRowHeight: CGFloat = 52.0
    let defaultSubMenuHeight: CGFloat = 40.0
    let defaultHeaderHeight: CGFloat = 52.0
    let userHeaderHeight: CGFloat = 92.0
    let footerFontSize: CGFloat = 15.0
    
    var menuItems = [MenuBase]()
    var dataManager = BCGSDataManager.sharedInstance
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var treeView: RATreeView!
    @IBOutlet weak var gradientView: UIView!

    private let xibName = "MainMenuTableViewCell"
    
    override dynamic func viewDidLoad() {
        
        self.view.backgroundColor = Style.Color.menu1Blue
        
        menuItems = MTMenuService.shared.buildMenu()
        
        treeView.delegate = self
        treeView.dataSource = self
        treeView.separatorColor = UIColor.clear
        treeView.collapsesChildRowsWhenRowCollapses = true
        
        treeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(treeView)
        treeView.reloadData()
        
        treeView.register(
            UINib(nibName: xibName, bundle: nil),
            forCellReuseIdentifier: xibName)
    }
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return menuItems.count
        }
        
        if let section = item as? Section {
            return section.items.count
        }
        
        return 0
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        guard let cell = treeView.dequeueReusableCell(withIdentifier: xibName) as? MainMenuTableViewCell else {
            fatalError("Expected a MainMenuTableViewCell object.")
        }

        var expanded = false
        if let menuItem = item as? MenuBase {
            cell.titleLabel.text = menuItem.name
            cell.setItemLevel(menuItem.level)
        }
            
        if let sectionItem = item as? Section {
            expanded = treeView.isCell(forItemExpanded: sectionItem)
        }
        
        cell.setIcon(item is Section,
                     isOpen: expanded)
        
        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return menuItems[index]
        }
        
        if let menuItem = item as? Section {
            return menuItem.items[index]
        }
        
        return index as AnyObject
    }
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        treeView.deselectRow(forItem: item, animated: true)
        
        if let item = item as? MenuItem {
            // TODO: Open playlist screen
            self.collapseMenu()
            slideMenuController()?.toggleLeft()
            
            if let playlistStr = item.playlist as NSString? {
                guard let stringsFile = ConfigController.sharedInstance.stringsFilename else {
                    fatalError("Could not get strings filename.")
                }
                
                if item.playlist == "FAVORITES_TITLE".localized(stringsFile) {
                    Controllers.favorites()
                    return
                } else if item.playlist == "RECENT_TITLE".localized(stringsFile) {
                    Controllers.recent()
                    return
                }
                else if item.playlist == "SUBSCRIPTION_INFO".localized(stringsFile) {
                    let message = "SUBSCRIPTION_TEXT".localized(stringsFile)
                    MTUserManager.shared.displayBasicAlert(message)
                    return
                }
                else if item.playlist == "PRIVACY_POLICY".localized(stringsFile) {
                    if let url = ConfigController.sharedInstance.privacy_url {
                        Controllers.open(with: url)
                    } else {
                        Controllers.open(with: "http://www.mathtutordvd.com/public/department12.cfm")
                    }
                    return
                }
                else if item.playlist == "TERMS_OF_USE".localized(stringsFile) {
                    if let url = ConfigController.sharedInstance.terms_url {
                        Controllers.open(with: url)
                    } else {
                        Controllers.open(with: "http://www.mathtutordvd.com/public/73.cfm")
                    }
                    return
                }
                else if item.playlist == "ABOUT_INSTRUCTOR".localized(stringsFile) {
                    if let url = ConfigController.sharedInstance.about_url {
                        Controllers.open(with: url)
                    } else {
                        Controllers.open(with: "http://www.mathtutordvd.com/public/department90.cfm")
                    }
                    return
                }

                Controllers.push(with: playlistStr as String, courseTitle: item.name)
            }
            
            return
        }

        if let cell = treeView.cell(forItem: item) as? MainMenuTableViewCell {
            cell.setIcon(item is Section,
                         isOpen: !treeView.isCellExpanded(cell))
        }
    }
    
    func treeView(_ treeView: RATreeView, canEditRowForItem item: Any) -> Bool {
        return false
    }
    
    fileprivate func collapseMenu() {
        if let cells = treeView.visibleCells() as? [UITableViewCell] {
            for cell in cells {
                if treeView.isCellExpanded(cell) {
                    if let item = treeView.item(for: cell) {
                        treeView.collapseRow(forItem: item)
                    }
                }
            }
        }
        
        treeView.reloadData()
    }
}
