//
//  MyPricePalTests.swift
//  MyPricePalTests
//
//  Created by Justin Lee on 5/2/19.
//  Copyright © 2019 CS48. All rights reserved.
//
import XCTest

@testable import MyPricePal
class MyPricePalTests: XCTestCase {
    
    var mainVC: MainViewController?
    var searchVC: SearchViewController?
    
    override func setUp() {
        mainVC = MainViewController()
        searchVC = SearchViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAddItem(){
        searchVC?.giveItemScanned(itemN: "Carmex Lip Balm", barcodeString: "083078113131", keywordString: ["Lip"], priceArray: ["10"])
        XCTAssert(searchVC?.returnNumItems() == 1, "SearchVC does not have the correct amount of items")
    }
    
    func testAddMaxItems() {
        
        for i in 0...searchVC!.maxItems {
            searchVC?.giveItemScanned(itemN: "Deodorant\(i)", barcodeString: "08307811313\(i)", keywordString: ["Deodorant"], priceArray: ["10"])
        }
        
        XCTAssert(searchVC?.returnNumItems() == searchVC?.maxItems, "SearchVC added \(String(describing: searchVC?.returnNumItems())) items")
        XCTAssert(searchVC!.items[0].itemN == "Deodorant\(searchVC!.maxItems)", "\(searchVC!.items[0].itemN) != Deodorant\(searchVC!.maxItems)")
        XCTAssert(searchVC?.items[(searchVC?.maxItems)! - 1].itemN == "Deodorant\(1)", "not Deodorant 1")
    }
    
    func testShiftItems() {
        searchVC?.giveItemScanned(itemN: "Deodorant", barcodeString: "083078113131", keywordString: ["Deodorant"], priceArray: ["10"])
        searchVC?.giveItemScanned(itemN: "Carmex Lip Balm", barcodeString: "083078113132", keywordString: ["Lip"], priceArray: ["10"])
        searchVC?.giveItemScanned(itemN: "popcorn", barcodeString: "083078113133", keywordString: ["Lip"], priceArray: ["10"])
        searchVC?.giveItemScanned(itemN: "Deodorant", barcodeString: "083078113131", keywordString: ["Deodorant"], priceArray: ["10"])
        
        XCTAssert(searchVC?.items[0].itemN == "Deodorant", "Deodorant != \(searchVC!.items[0])")
        XCTAssert(searchVC?.items[1].itemN == "popcorn", "popcorn != \(searchVC!.items[1])")
        XCTAssert(searchVC?.items[2].itemN == "Carmex Lip Balm", "Carmex Lip Balm != \(searchVC!.items[2])")
        
    }
    func testDeleteCell() {
        searchVC?.giveItemScanned(itemN: "Deodorant", barcodeString: "083078113131", keywordString: ["Deodorant"], priceArray: ["10"])
        searchVC?.giveItemScanned(itemN: "Carmex Lip Balm", barcodeString: "083078113132", keywordString: ["Lip"], priceArray: ["10"])
        searchVC?.giveItemScanned(itemN: "popcorn", barcodeString: "083078113133", keywordString: ["Lip"], priceArray: ["10"])
        let tableView = searchVC?.tableView
        let deletionIndexPath = IndexPath(item: 0, section: 0)
        let cell = tableView?.cellForRow(at: deletionIndexPath)
        searchVC?.deleteCell(cell: cell!)
        
        XCTAssert(searchVC?.items[0].itemN == "Carmex Lip Balm", "items[0] = \(String(describing: searchVC?.items[0]))")
        XCTAssert(searchVC?.items[1].itemN == "Deodorant", "items[1] = \(String(describing: searchVC?.items[1]))")
    }
    
    func testLoadViewItemVC() {
        let itemVC = ItemViewController()
        itemVC.loadView()
        itemVC.viewDidLoad()
    }
    
    
    
    //   func testGetItem() {
    //    let barcodeString = "022000005120"
    
    //        let itemForBarcode = "DDI 952815 5 Cobalt Gum 15 PC 10 Count Case of 10"
    //
    //        let urlBase = "https://api.upcitemdb.com/prod/trial/lookup?upc=" //barcodeString and urlBase combine to create the url
    //        let url = URL(string: urlBase + barcodeString)!
    //        let task = URLSession.shared.dataTask(with: url){(data, resp, error) in //Creates the url connection to the API
    //            guard let data = data else{
    //                print("data was nil")
    //                return
    //            }
    //            guard let htmlString = String(data: data, encoding: String.Encoding.utf8)else{//Saves the html with the JSON into a string
    //                print("cannot cast data into string")
    //                return
    //
    //            }
    //            let leftSideOfTheValue = """
    //            title":"
    //            """
    //            //Left side before the desired value in the JSON portion of the HTML
    //            let rightSideOfTheValue = """
    //            ","description
    //            """
    //            //right side after the desired value in the JSON portion of the HTML
    //            guard let leftRange = htmlString.range(of: leftSideOfTheValue)else{
    //
    //                XCTAssert(false)
    //                return
    //            }//Creates left side range
    //            guard let rightRange = htmlString.range(of: rightSideOfTheValue)else{
    //
    //                XCTAssert(false)
    //                return
    //            }//Creates right side range
    //            let rangeOfTheValue = leftRange.upperBound..<rightRange.lowerBound //Appends the ranges together
    //
    //            XCTAssert(String(htmlString[rangeOfTheValue]) == itemForBarcode, "\(String(htmlString[rangeOfTheValue])) != \(itemForBarcode)")
    //        }
    //        task.resume()
    //    }
    
    
}
