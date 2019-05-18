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

class ItemViewController: UITableViewController {
    
    struct responseJSON: Decodable{
        let response: responseType
        //        let entities: [Content]
    }
    
    struct responseType: Decodable{
        let entities: [Content]
    }
    
    struct Content: Decodable{
        let entityEnglishId: String
    }
    
    var items: [String] = ["Costco: ","Walmart: ", "Amazon: ", "Albertsons: "]
    
    var exact: Bool?
    
    public weak var dismissalDelegate: ItemViewDismissalDelegate?
    public weak var urlDelegate: ItemViewURLDelegate?
//    public let textView = UITextView(frame: .zero)

    public var barcodeNum: String?
    public var keywordString: String?
    
    var itemN: String? {
        didSet {
            self.titleLabel.text = itemN
        }
    }

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
    func truncateName(){
        let urlString = "https://api.textrazor.com/"
        let headers = [
            "x-textrazor-key" : "55864c94efce2b09deef214d17c8de7f0eeb73573655571c5ca9125b"
        ]
        var z : String = ""
        let x : String = "text=" + itemN!
        let y : String = x + "&extractors=entities"
        let postData = NSMutableData(data: y.data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 1.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        let task = URLSession.shared.dataTask(with: request as URLRequest){ (data, response, error) in
            if let data = data{
                do{
                    let JSONinfo = try JSONDecoder().decode(responseJSON.self, from: data)
                    for i in (JSONinfo.response.entities).indices{
                        z = z + JSONinfo.response.entities[i].entityEnglishId
                    }
                    self.keywordString = z
                }catch{
                    print(error)
                }
                return
            }
        }
        task.resume()
    }
    
    override func loadView() {
        super.loadView()
        truncateName()
        tableView.register(ItemViewItemCell.self, forCellReuseIdentifier: "itemCellId")
        tableView.register(ItemViewHeader.self, forHeaderFooterViewReuseIdentifier: "itemHeaderId")
        
        tableView.sectionHeaderHeight = 50
        view.backgroundColor = .white
        navigationItem.titleView = titleLabel
        let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissalAction(sender:)))
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.titleView = titleLabel
 
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            if(exact==false){
                let urlBase = "https://www.amazon.com/s?k="
                let urlEnd = "&i=grocery&crid=1RQ40Q09MZBMW&sprefix=5+gum%2Caps%2C189&ref=nb_sb_ss_c_2_5"
                let item = keywordString!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                urlDelegate?.showSafariVC(urlBase + item + urlEnd)
            }
            else{
                let urlBase = "https://www.amazon.com/s?k="
                let urlEnd = "&ref=nb_sb_nos"
                urlDelegate?.showSafariVC(urlBase + barcodeNum! + urlEnd)
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCellId", for: indexPath) as! ItemViewItemCell
        
        itemCell.nameLabel.text = items[indexPath.row]
 //       itemCell.logo.image = itemImages[indexPath.row]
//        itemCell.logo.clipsToBounds = true
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
           nameLabel.anchor.left.constant(16),
           nameLabel.anchor.centerY
        )
    }
}

class ItemViewItemCell: UITableViewCell {
    
    var itemViewController: ItemViewController?
    
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
        addSubview(actionButton)
        addSubview(nameLabel)

        actionButton.addTarget(self, action: #selector(handleAction(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel, "v1": actionButton]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]-20-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": actionButton]))
    }
    
    @objc func handleAction(sender: UIButton) {
        itemViewController?.deleteCell(cell: self)
    }
}
