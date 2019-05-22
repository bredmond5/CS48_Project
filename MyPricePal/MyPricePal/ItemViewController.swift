//
//  ItemViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/19/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import Foundation
import Anchors

protocol ItemViewDismissalDelegate : class {
    func itemViewDidDismiss(_ controller: ItemViewController)
}

protocol ItemViewURLDelegate: class {
    func showSafariVC(_ url: String)
}

struct InfoStruct {
    let company: String?
    let price: String?
    let url: String?
}

class ItemViewController: UITableViewController {

    var priceArray: [String] = [String]() {
        didSet {
            var firstSet = [InfoStruct]()
            let google = InfoStruct(company: "Google Shopping", price: "", url: priceArray[0])
            firstSet.append(google)
            
            var maxItems = 6
            var i = 1
            if(priceArray.count < 1 + maxItems*3) {
                maxItems = (priceArray.count / 3)
            }
            while i < 1 + maxItems*3 {
                let infoStruct = InfoStruct(company: priceArray[i] + ": ", price: "$" + priceArray[i + 1], url: priceArray[i + 2])
                firstSet.append(infoStruct)
                i = i + 3
            }
            items.append(firstSet)
//            print(keywordString!)
            var placeholderArray = [InfoStruct]()
            for x in keywordString! {
                print(x)
                let placeholder = InfoStruct(company: x, price: "0", url: "http://www.engrish.com/")
                placeholderArray.append(placeholder)
            }
            items.append(placeholderArray)
        }
    }
    
    let sections = ["Cheapest Deals", "Cheapest Deals For Similar Items"]
    
    var items = [[InfoStruct]]()
    
    public weak var dismissalDelegate: ItemViewDismissalDelegate?
    public weak var urlDelegate: ItemViewURLDelegate?
//    public let textView = UITextView(frame: .zero)

    public var barcodeNum: String?
    public var keywordString: [String]?
    
    var itemN: String?

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        return label
    }()

    @objc func dismissalAction(sender: Any) {
        dismissalDelegate?.itemViewDidDismiss(self)
    }
    
    
    override func loadView() {
        super.loadView()
        tableView.register(ItemViewItemCell.self, forCellReuseIdentifier: "itemCellId")
        tableView.register(ItemViewHeader.self, forHeaderFooterViewReuseIdentifier: "itemHeaderId")
        
        tableView.sectionHeaderHeight = 50
        view.backgroundColor = .white
        let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissalAction(sender:)))
        navigationItem.leftBarButtonItem = backBarButton
        titleLabel.text = itemN
        titleLabel.adjustsFontSizeToFitWidth = true
//        activate(
//        titleLabel.anchor.right.constant(30)
//        )
        titleLabel.numberOfLines = 2
        navigationItem.titleView = titleLabel
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ItemViewItemCell
        urlDelegate?.showSafariVC(cell.url!)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCellId", for: indexPath) as! ItemViewItemCell
        
        itemCell.company.text = items[indexPath.section][indexPath.row].company
        itemCell.price.text = items[indexPath.section][indexPath.row].price
        itemCell.url = items[indexPath.section][indexPath.row].url
        itemCell.contentMode = .scaleAspectFit
        itemCell.itemViewController = self
        
        itemCell.setupViews()
        return itemCell
    }
    
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            items.remove(at: deletionIndexPath.row)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "itemHeaderId") as! ItemViewHeader
        header.nameLabel.text = sections[section]
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
}

class ItemViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been initialized")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
    
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        activate(
           nameLabel.anchor.left.constant(16),
           nameLabel.anchor.right.constant(16),
           nameLabel.anchor.centerY,
           nameLabel.anchor.size
        )
    }
}

class ItemViewItemCell: UITableViewCell {
    
    var itemViewController: ItemViewController?
    
    var url: String?
    
    var mainImageView : UIImageView = {
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        imageView.image = UIImage(named: "imageC.jpg")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
//    var logo: UIImageView = {
//        let logo = UIImageView(frame: .zero)
//        logo.translatesAutoresizingMaskIntoConstraints = false
//        return logo
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been initialized")
    }
    
    let company: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let price: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
//    let actionButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Delete", for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    func setupViews() {
//        addSubview(actionButton)
        addSubview(company)
        addSubview(price)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(40)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": company, "v1": price]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": company]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": price]))
    }
    
//    @objc func handleAction(sender: UIButton) {
//        itemViewController?.deleteCell(cell: self)
//    }
}
