//
//  SwiftChartsViewController.swift
//  MyPricePal
//
//  Created by Sai Kathika on 5/24/19.
//  Copyright © 2019 CS48. All rights reserved.
//

import UIKit
import SwiftCharts

class SwiftsChartsViewController: UIViewController{
    var chartView: BarsChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add_products("Apple")
        //        storeData()
        //        getData()
        //        if let x = UserDefaults.standard.object(forKey: "searched") as? Double{
        //            getData(x, 0, 0)
        //        }
        //        if let y = UserDefaults.standard.object(forKey: "scanned") as? Double{
        //            setData(Int32(return_products_scanned()), Int32(y), 3)
        //        }
        //        if let z = UserDefaults.standard.object(forKey: "inputed") as? Double{
        //            setData(Int32(return_products_scanned()),Int32(return_products_searched()) , Int32(z))
        //        }
        
        //        var titleLabel: UILabel = {
        //            let label = UILabel()
        //            label.text = "User Statistics"
        //            label.font = UIFont.boldSystemFont(ofSize: 36)
        //            label.numberOfLines = 1
        //            label.textAlignment = .center
        //            label.textColor = .red
        //            label.sizeToFit()
        //            return label
        //        }()
        //        override func loadView() {
        //            super.loadView()
        //            view.backgroundColor = .white
        //            navigationItem.titleView = titleLabel
        //        }
        
        
        //        add_products(Int8("Lays")!)
        //        add_products(Int8("Apple")!)
        //        add_products(Int8("pear")!)
        //        print_elements()
        //        let average = (return_products_scanned()+return_products_searched()+return_products_added()/3)
        // update_products_searched()
        // update_products_scanned()
        // update_products_added()
        
        let average = (return_products_scanned()+return_products_searched()+return_products_added()+6/3)
        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from:0,to:average,by:1))
        
        let frame = CGRect(x: 5, y: 90, width: self.view.frame.width, height: 450)
        // getData(30, 25, 38)
        
        let chart = BarsChart(frame: frame, chartConfig: chartConfig, xTitle: "User Actions within app", yTitle: "Number of Scans per Session", bars: [                                                                             ("Scanned",return_products_scanned()),("URL's Clicked",return_url()),("Inputed",return_products_added()),],
                              
                              color: UIColor.black, barWidth: 60)
        self.view.addSubview(chart.view)
        self.chartView = chart
        view.backgroundColor = .white
        
    }
    //    func viewDidAppear() {
    //        super.viewDidAppear(true)
    //        getData()
    //    }
    //    func viewDidDisappear() {
    //        super.viewDidDisappear(true)
    //        storeData()
    //    }
    func storeData(){
        UserDefaults.standard.set(return_products_scanned(),forKey: "scanned")
        //defaults?.synchronize()
    }
    func getData(){
        let data = UserDefaults.value(forKey: "scanned")
        var x = return_products_scanned()
        x = data as! Double
        set_scanned(x)
    }
    
}
