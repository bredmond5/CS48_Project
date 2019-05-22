//
//  ChartViewController.swift
//  C++
//
//  Created by Sai Kathika on 5/18/19.
//  Copyright © 2019 Sai Kathika. All rights reserved.
//

import Foundation
protocol GetChartData{
    func getChartData(with dataPoints:[String], values: [String])
    var workoutDuration: [String] {get set}
    var beatsPerMinute: [String] {get set}
}
class ChartViewController: UIViewController, GetChartData{
    var workoutDuration =  [String]()
    var beatsPerMinute =   [String]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        populateChartData()
        barchart()
    }
    
    func populateChartData(){
        workoutDuration = ["1","2","3","4","5","6","7","8","9","10"]
        beatsPerMinute = ["76","150","160","195","195","180","164","136","112"]
        self.getChartData(with: workoutDuration, values:beatsPerMinute)
    }
    
    func barChart(){
        let barChart = BarChart(frame: CGRect(x:0.0, y:0.0, width: self.view.frame.width,height: self.view.frame.height))
        barChart.delegate = self
        self.view.addSubview(barChart)
    }
}
