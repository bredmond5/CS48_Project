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
    
    var build: MainViewController?
    var searchVC: SearchViewController?

    override func setUp() {
        build = MainViewController()
        searchVC = SearchViewController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAddItem(){
        searchVC?.giveItemScanned("Deodorant")
        XCTAssert(searchVC?.returnNumItems() == 1, "SearchVC does not have the correct amount of items")
    }
    
    func testAddMaxItems() {
        
        for i in 0...searchVC!.maxItems {
            searchVC?.giveItemScanned("Deodorant \(i)")
        }
        
        XCTAssert(searchVC?.returnNumItems() == searchVC?.maxItems, "SearchVC added \(searchVC?.returnNumItems()) items")
        XCTAssert(searchVC!.items[0] == "Deodorant \(searchVC!.maxItems)", "\(searchVC!.items[0]) != Deodorant \(searchVC!.maxItems)")
        XCTAssert(searchVC?.items[(searchVC?.maxItems)! - 1] == "Deodorant \(1)", "not Deodorant 1")
    }
    
    func testShiftItems() {
        searchVC?.giveItemScanned("Deodorant")
        searchVC?.giveItemScanned("Gum")
        searchVC?.giveItemScanned("Binder")
        searchVC?.giveItemScanned("Deodorant")
        
        XCTAssert(searchVC?.items[0] == "Deodorant", "Did not shift correctly")
        XCTAssert(searchVC?.items[2] == "Gum", "Gum not shifted correctly")
    }
    
    func testDeleteCell() {
        searchVC?.giveItemScanned("Deodorant")
        searchVC?.giveItemScanned("Gum")
        searchVC?.giveItemScanned("Binder")
        let tableView = searchVC?.tableView
        let deletionIndexPath = IndexPath(item: 0, section: 0)
        let cell = tableView?.cellForRow(at: deletionIndexPath)
        searchVC?.deleteCell(cell: cell!)
        
        XCTAssert(searchVC?.items[0] == "Gum", "items[0] = \(searchVC?.items[0])")
        XCTAssert(searchVC?.items[1] == "Deodorant", "items[1] = \(searchVC?.items[1])")
    }
    
    
}

