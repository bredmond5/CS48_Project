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
    
        let average = (return_products_scanned()+return_products_searched()+return_products_added()+6/3)
        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from:0,to:average,by:1))
        
        let frame = CGRect(x: 5, y: 90, width: self.view.frame.width, height: 450)
  
        
        let chart = BarsChart(frame: frame, chartConfig: chartConfig, xTitle: "User Actions within app", yTitle: "Number of Scans per Session", bars: [                                                                             ("Scanned",return_products_scanned()),("URL's Clicked",return_url()),("Inputed",return_products_added()),],
                              
                              color: UIColor.black, barWidth: 60)
        self.view.addSubview(chart.view)
        self.chartView = chart
        view.backgroundColor = .white
        
    }

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

