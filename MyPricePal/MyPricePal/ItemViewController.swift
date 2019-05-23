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
                selected.append(false)
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
<<<<<<< HEAD
    public var itemN: String?
    
//    func parseHTMLDoc(){
//        do {
//            let html = "<html><head><title>First parse</title></head>"
//                + "<body><p>Parsed HTML into a doc.</p></body></html>"
//            let doc: Document = try SwiftSoup.parse(html)
//            return try doc.text()
//        } catch Exception.Error(let type, let message) {
//            print(message)
//        } catch {
//            print("error")
//        }
//    }
   
=======

    public var barcodeNum: String?
    public var keywordString: [String]?
    public var selected: [Bool] = []
    var itemN: String?
>>>>>>> c277e16e19dccc2eb5d4005c6cfa231b6509bf06
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
    
//    @objc func refreshAction(_ sender: Any) {
//        //Get the new stuff with the new keywords
//        //then:
//
//        tableView.deleteRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>)
//
//        var indexPaths = [NSIndexPath]()
//        for i in 0..<items[1].count {
//            indexPaths.append(NSIndexPath(row: i, section: 1))
//        }
//
//        var bottomHalfIndexPaths = [NSIndexPath]()
//        for _ in  0...indexPaths.count / 2 - 1 {
//            bottomHalfIndexPaths.append(indexPath.removeLast())
//        }
//
//        tableView.beginUpdates()
//        tableView.insertRows(at: indexPaths, with: .right)
//        tableView.insertRows(at: bottomHalfIndexPaths, with: .left)
//        tableview.endUpdates()
//    }
    
    
    override func loadView() {
        super.loadView()
        tableView.register(ItemViewItemCell.self, forCellReuseIdentifier: "itemCellId")
        tableView.register(ItemViewHeader.self, forHeaderFooterViewReuseIdentifier: "itemHeaderId")
        tableView.register(SecondHeader.self, forHeaderFooterViewReuseIdentifier: "secondHeaderId")
        
        tableView.sectionHeaderHeight = 50

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissalAction(sender:)))
      
        tableView.allowsMultipleSelection = true
        view.backgroundColor = .white
        
        titleLabel.text = itemN
        titleLabel.adjustsFontSizeToFitWidth = true
//        activate(
//        titleLabel.anchor.right.constant(30)
//        )
        titleLabel.numberOfLines = 2
        navigationItem.titleView = titleLabel
    }
//    class SAButton: UIButton {
//
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            setupButton()
//        }
//
//
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//            setupButton()
//        }
//
//
//        private func setupButton() {
//            setTitleColor(.white, for: .normal)
//            backgroundColor     = UIColor(red: 255/255, green: 5/255, blue: 41/255, alpha: 1.0)
//            titleLabel?.font    = .boldSystemFont(ofSize: 20)
//            layer.cornerRadius  = frame.size.height / 2
//        }
//    }
//    @IBAction func watchButtonTapped(_sender: SAButton) {
//        showSafariVC(for: "https://www.amazon.com/s?k=lays&ref=nb_sb_noss_1")
//    }
//
    
//    func showSafariVC(for url: String) {
//        guard let url = URL(string: url) else {
//            //Show an invalid URL error alert
//            return
//        }
//        
//        let safariVC = SFSafariViewController(url: url)
//        present(safariVC, animated: true)
//    }
    
<<<<<<< HEAD
    override func viewDidLoad() {
        tableView.register(ItemViewItemCell.self, forCellReuseIdentifier: "itemCellId")
        tableView.register(ItemViewHeader.self, forHeaderFooterViewReuseIdentifier: "itemHeaderId")
        
         tableView.sectionHeaderHeight = 50
        
//        let url1 = URL(string: "https://www.amazon.com/s?k=lays&ref=nb_sb_noss_1")
//        if (UIApplication.shared.canOpenURL(url1)) {
//            UIApplication.shared.openURL(url1)
//        }
=======
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
>>>>>>> c277e16e19dccc2eb5d4005c6cfa231b6509bf06
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ItemViewItemCell
        if(indexPath.section == 0){
            urlDelegate?.showSafariVC(cell.url!)
        }
        else{
            var selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            selectedCell.contentView.backgroundColor = UIColor.cyan
            selected[indexPath.row] = true

        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        var cellToDeselect:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeselect.contentView.backgroundColor = UIColor.white
        selected[indexPath.row] = false
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
            return header
        }
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

class SecondHeader: ItemViewHeader {
    
    @objc func amazonAction(_ sender: UIButton) {
        //open up amazon
        print("amazonAction pressed")
    }
    
    @objc func googleShoppingAction(_ sender: UIButton) {
        //open up google
        print("googleShoppingActionPressed")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been initialized")
    }
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Shops: "
        label.sizeToFit()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let amazonButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.text = "Amazon"
        button.addTarget(self, action: #selector(amazonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let googleShoppingButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.text = "Google Shopping"
        button.addTarget(self, action: #selector(googleShoppingAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func layoutViews() {
        addSubview(label)
        addSubview(amazonButton)
        addSubview(googleShoppingButton)
        
        activate(
           label.anchor.top.equal.to(nameLabel.anchor.bottom).constant(10),
           label.anchor.left.equal.to(nameLabel.anchor.left),
           
           amazonButton.anchor.centerY.equal.to(label.anchor.centerY),
           amazonButton.anchor.left.equal.to(label.anchor.right).constant(15),
           
           googleShoppingButton.anchor.centerY.equal.to(label.anchor.centerY),
           googleShoppingButton.anchor.left.equal.to(amazonButton.anchor.left).constant(15)
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
    
    func setupViews() {
        addSubview(company)
        addSubview(price)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(60)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": company, "v1": price]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": company]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": price]))
    }
}
