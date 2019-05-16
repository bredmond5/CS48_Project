//
//  ItemViewController.swift
//  MyPricePal
//
//  Created by Brice Redmond on 4/19/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import Anchors

protocol ItemViewDismissalDelegate : class {
    func itemViewDidDismiss(_ controller: ItemViewController)
}

class ItemViewController: UITableViewController {
    
    var items: [String] = ["Costco: ","Walmart: ", "Amazon: ", "Albertsons: "]

    public weak var dismissalDelegate: ItemViewDismissalDelegate?
//    public let textView = UITextView(frame: .zero)
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
        view.backgroundColor = .white
        titleLabel.text = itemN
        navigationItem.titleView = titleLabel
        let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissalAction(sender:)))
        navigationItem.leftBarButtonItem = backBarButton
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
    
    override func viewDidLoad() {
        tableView.register(ItemViewItemCell.self, forCellReuseIdentifier: "itemCellId")
        tableView.register(ItemViewHeader.self, forHeaderFooterViewReuseIdentifier: "itemHeaderId")
        
         tableView.sectionHeaderHeight = 50
        
//        let url1 = URL(string: "https://www.amazon.com/s?k=lays&ref=nb_sb_noss_1")
//        if (UIApplication.shared.canOpenURL(url1)) {
//            UIApplication.shared.openURL(url1)
//        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCellId", for: indexPath) as! ItemViewItemCell
        itemCell.nameLabel.text = items[indexPath.row]
        itemCell.itemViewController = self
        return itemCell
    }
    
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            items.remove(at: deletionIndexPath.row)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "itemHeaderId")
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
        label.text = "Best Prices:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)
        activate(
           nameLabel.anchor.center
        )
    }
}

class ItemViewItemCell: UITableViewCell {
    
    var itemViewController: ItemViewController?
    
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
        itemViewController?.deleteCell(cell: self)
    }
}
