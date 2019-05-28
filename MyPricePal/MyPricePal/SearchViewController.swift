//
//  SearchViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/19/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import Foundation
import UIKit
import Anchors

protocol SearchRequestedDelegate: class {
    func searchRequested(_ barcodeString: String, _ itemN: String, _ keywordString: [String])
}

//SearchViewController handles showing the user their recent searches and sending items
//to the itemVC if they are pressed.

class SearchViewController: UITableViewController {
    public weak var searchRequestedDelegate: SearchRequestedDelegate?
    
    //These are shown as the items in the table. Defaults to zero items.
    var items: [(barcodeString: String, itemN: String, keyWordString: [String])] = []
    
    var maxItems = 11 //Maximum amount of items shown
    
    //Set up the navigationBar UILabel
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Searched Items"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        return label
    }()
    
    func returnNumItems() -> Int{return items.count}
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        navigationItem.titleView = titleLabel
        tableView.isScrollEnabled = false
    }
    
    //Function called by MainViewController to give the scanned item.
    public func giveItemScanned(_ itemN: String, _ barcodeString: String, _ keywordString: [String]) {
        
        var index = -1
        for i in 0..<items.count {
            if items[i].barcodeString == barcodeString {
                index = i
            }
        }
        
        if index != -1 {
            items.remove(at: index)
            let deletionIndexPath = IndexPath(item: index, section: 0)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
        
        items.insert((barcodeString, itemN, keywordString), at: 0)
        resizeTable()
       
        if(items.count == maxItems + 1) {
            let deletionIndexPath = IndexPath(item: items.count - 1, section: 0)
            deleteCell(cell: tableView.cellForRow(at: deletionIndexPath)!)
        }
        
        tableView.reloadData()
    }
    
    func resizeTable() {
        let insertionIndexPath = IndexPath(item: items.count - 1, section: 0)
        tableView.insertRows(at: [insertionIndexPath], with: .automatic)
    }
    
    
    //Sets up all the cell stuff for the tableView so that we see rows.
    override func viewDidLoad() {
        tableView.register(SearchViewItemCell.self, forCellReuseIdentifier: "cellId")
        tableView.sectionHeaderHeight = 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchViewItemCell
        itemCell.nameLabel.text = items[indexPath.row].itemN
        itemCell.barcodeString = items[indexPath.row].barcodeString
        itemCell.searchViewController = self
        return itemCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchRequestedDelegate?.searchRequested(items[indexPath.row].barcodeString, items[indexPath.row].itemN, items[indexPath.row].keyWordString)
    }
    
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            items.remove(at: deletionIndexPath.row)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
}

class SearchViewItemCell: UITableViewCell {
    
    var searchViewController: SearchViewController?
    
    var barcodeString: String?
    var keywordString: [String]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been initialized")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 189/255.0, green: 66/255.0, blue: 74/255.0, alpha: 1), for: .normal)
        button.setTitle("Delete", for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(actionButton)
        
        actionButton.addTarget(self, action: #selector(handleAction(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel, "v1": actionButton]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[v0]-12-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[v0]-12-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": actionButton]))
    }
    
    @objc func handleAction(sender: UIButton) {
        searchViewController?.deleteCell(cell: self)
    }
}

