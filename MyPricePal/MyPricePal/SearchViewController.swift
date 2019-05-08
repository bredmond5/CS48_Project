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

protocol SearchViewControllerDismissalDelegate: class {
    func searchViewDidDismiss(_ controller: SearchViewController)
}

protocol SearchRequestedDelegate: class {
    func searchRequested(_ item: String)
}

class SearchViewController: UITableViewController {
    
    public weak var dismissalDelegate: SearchViewControllerDismissalDelegate?
    
    public weak var searchRequestedDelegate: SearchRequestedDelegate?
    
    var items: [String] = []
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Searched Items"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    @objc func dismissalAction(sender: Any) {
        dismissalDelegate?.searchViewDidDismiss(self)
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        navigationItem.titleView = titleLabel
        tableView.isScrollEnabled = false
    }
    
    public func giveItemScanned(_ item: String) {
        for x in items {
            if(x == item) {
                return
            }
        }
        items.insert(item, at: 0)
        let insertionIndexPath = IndexPath(item: items.count - 1, section: 0)
        tableView.insertRows(at: [insertionIndexPath], with: .automatic)
        tableView.reloadData()
        if(items.count == 11) {
            let deletionIndexPath = IndexPath(item: items.count - 1, section: 0)
            deleteCell(cell: tableView.cellForRow(at: deletionIndexPath)!)
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        tableView.register(SearchViewItemCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(SearchViewHeader.self, forHeaderFooterViewReuseIdentifier: "headerId")
        
        tableView.sectionHeaderHeight = 0
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Insert", style: .plain, target: self, action: #selector(insert(sender:)))
    }
    
    @objc func insert(sender: UIBarButtonItem) {
        items.append("Item \(items.count + 1)")
        
        let insertionIndexPath = IndexPath(item: items.count - 1, section: 0)
        tableView.insertRows(at: [insertionIndexPath], with: .automatic)
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchViewItemCell
        itemCell.nameLabel.text = items[indexPath.row]
        itemCell.searchViewController = self
        return itemCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchRequestedDelegate?.searchRequested(items[indexPath.row])
    }
    
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            items.remove(at: deletionIndexPath.row)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
}

class SearchViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been initialized")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Items"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Search"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        return textField
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(textField)
        activate(
            textField.anchor.center,
            textField.anchor.top.bottom
        )
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[v0]-12-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
}

class SearchViewItemCell: UITableViewCell {
    
    var searchViewController: SearchViewController?
    
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

