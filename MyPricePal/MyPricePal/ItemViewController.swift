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
import SafariServices


protocol ItemViewDismissalDelegate : class {
    func itemViewDidDismiss(_ controller: ItemViewController)
}

protocol ItemViewURLDelegate: class {
    func showSafariVC(_ url: String)
}

class InfoStruct {
    var company: String? = nil
    var price: String? = nil
    var url: String? = nil
    
    init(company: String, price: String, url: String) {
        self.company = company
        self.price = price
        self.url = url
    }
    
    func changePrice(price: String) {
        self.price = price
    }
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
                let infoStruct = InfoStruct(company: priceArray[i] + ": ", price:  priceArray[i + 1], url: priceArray[i + 2])
                firstSet.append(infoStruct)
                i = i + 3
            }

            items.append(sort(firstSet))
//            print(keywordString!)
            var keywordArray = [InfoStruct]()
            for x in keywordString! {
                let keywordStruct = InfoStruct(company: x, price: "", url: "")
                keywordArray.append(keywordStruct)
            }
            items.append(keywordArray)
        }
    }
    
    func sort(_ arrayGiven: [InfoStruct]) -> [InfoStruct]{
        var array = arrayGiven
        for _ in 1..<array.count {
            for j in 2..<array.count {
                if Double(array[j].price!)! < Double(array[j-1].price!)! {
                    let tmp = array[j-1]
                    array[j-1] = array[j]
                    array[j] = tmp
                }
            }
        }
        
        for i in 1..<array.count {
            let num = Double(array[i].price!)
            array[i].price = String(format: "$%.02f", num!)
        }
        
        return array
    }
    
    let sections = ["Cheapest Deals For Your Item: ", "Select Keywords then Search by Shop: "]
    
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
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()

    @objc func dismissalAction(sender: Any) {
        dismissalDelegate?.itemViewDidDismiss(self)
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white

        tableView.register(ItemViewItemCell.self, forCellReuseIdentifier: "itemCellId")
        tableView.register(ItemViewHeader.self, forHeaderFooterViewReuseIdentifier: "itemHeaderId")
        tableView.register(SecondHeader.self, forHeaderFooterViewReuseIdentifier: "secondHeaderId")
        
//        tableView.estimatedSectionHeaderHeight = 75
//        tableView.sectionHeaderHeight = UITableView.automaticDimension
//
        tableView.sectionHeaderHeight = 60
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissalAction(sender:)))
      
        tableView.allowsMultipleSelection = true
        
        titleLabel.text = itemN
        navigationItem.titleView = titleLabel
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ItemViewItemCell
        if(indexPath.section == 0){
            urlDelegate?.showSafariVC(cell.url!)
        }
        else{
            let selectedCell:ItemViewItemCell = tableView.cellForRow(at: indexPath)! as! ItemViewItemCell
            selectedCell.contentView.backgroundColor = UIColor.gray
            selectedCell.select = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cellToDeselect = tableView.cellForRow(at: indexPath)! as! ItemViewItemCell
        cellToDeselect.contentView.backgroundColor = UIColor.white
        cellToDeselect.select = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCellId", for: indexPath) as! ItemViewItemCell
        
        itemCell.company.text = items[indexPath.section][indexPath.row].company
        itemCell.price.text = items[indexPath.section][indexPath.row].price
        itemCell.url = items[indexPath.section][indexPath.row].url
        itemCell.contentMode = .scaleAspectFit
//        itemCell.backgroundColor = .black
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
        if(section == 0) {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "itemHeaderId") as! ItemViewHeader
            header.nameLabel.text = sections[0]
            return header
        }else{
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "secondHeaderId") as! SecondHeader
            header.nameLabel.text = sections[1]
            header.itemVC = self
            return header
        }
    }
    
    func getKeyWordsSelected() -> String{
        var fin: String = ""
        for i in 0..<items[1].count{
            let indexPath = IndexPath(row: i, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            if(cell?.isSelected == true){
                let str = keywordString![i].split(separator: " ")
                for j in 0..<str.count {
                    if(i==0 && j == 0){
                        fin = String(str[j])
                    }else{
                        fin+="+"
                        fin += String(str[j])
                    }
                }
            }
        }
        return fin
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
           nameLabel.anchor.size,
           nameLabel.anchor.bottom.constant(5),
           nameLabel.anchor.top.constant(5)
        )
    }
}

class SecondHeader: UITableViewHeaderFooterView {
    public weak var itemVC: ItemViewController?

    @objc func amazonAction(_ sender: UIButton) {
        let keywords = itemVC?.getKeyWordsSelected()
        let urlBase = "https://www.amazon.com/s?k="
        let urlEnd = "&ref=nb_sb_noss_2"
        let url1 = urlBase + keywords! + urlEnd
        
        itemVC?.urlDelegate?.showSafariVC(url1)
    }
    
    @objc func googleShoppingAction(_ sender: UIButton) {
        
        let keywords = itemVC?.getKeyWordsSelected()
        let urlBase = "https://www.google.com/search?tbm=shop&hl=en&source=hp&biw=&bih=&q="
        let urlMiddle = "&oq="
        let urlEnd = "&gs_l=products-cc.3..0l10.1951.3368.0.3664.11.5.0.6.6.0.72.331.5.5.0....0...1ac.1.34.products-cc..0.11.350.diyOR4lqfyQ"
        let url = urlBase + keywords! + urlMiddle + keywords! + urlEnd
        itemVC?.urlDelegate?.showSafariVC(url)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been initialized")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let shopsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Shops: "
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let amazonButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 189/255.0, green: 66/255.0, blue: 74/255.0, alpha: 1), for: .normal)
        button.setTitle("Amazon", for: .normal)
        button.addTarget(self, action: #selector(amazonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let googleShoppingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(red: 189/255.0, green: 66/255.0, blue: 74/255.0, alpha: 1), for: .normal)
        button.setTitle("Google Shopping", for: .normal)
        button.addTarget(self, action: #selector(googleShoppingAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func layoutViews() {
        addSubview(nameLabel)
        addSubview(shopsLabel)
        addSubview(amazonButton)
        addSubview(googleShoppingButton)
        
//        let layoutGuide = UILayoutGuide()
        
        activate(
            
            nameLabel.anchor.top.constant(5),
            nameLabel.anchor.left.constant(16),
            nameLabel.anchor.right.constant(16),
            nameLabel.anchor.bottom.equal.to(shopsLabel.anchor.top).constant(5),
            
           shopsLabel.anchor.left.equal.to(nameLabel.anchor.left),
           shopsLabel.anchor.bottom.constant(5),
           
           amazonButton.anchor.centerY.equal.to(shopsLabel.anchor.centerY),
           amazonButton.anchor.left.equal.to(shopsLabel.anchor.right).constant(16),
//           amazonButton.anchor.size.equal.to(shopsLabel.anchor.size),
           
           googleShoppingButton.anchor.centerY.equal.to(shopsLabel.anchor.centerY),
           googleShoppingButton.anchor.left.equal.to(amazonButton.anchor.right).constant(16)
//           googleShoppingButton.anchor.size.equal.to(amazonButton.anchor.size)
        )
    }
    
}

class ItemViewItemCell: UITableViewCell {
    
    var itemViewController: ItemViewController?
    var select: Bool = false
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
    
    func setupViews() {
        addSubview(company)
        addSubview(price)
        
        activate(
            company.anchor.left.constant(5),
            price.anchor.right.constant(-5),
            price.anchor.centerY
        )
        
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": company]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": company]))
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": price]))
    }
}
