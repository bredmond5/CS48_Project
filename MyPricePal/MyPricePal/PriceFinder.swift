//
//  ViewController.swift
//  TestAPI
//
//  Created by Sai Kathika on 5/12/19.
//  Copyright © 2019 Sai Kathika. All rights



import UIKit
import Foundation

protocol PriceFinderDelegate : class {
    func returnPrices(_ prices: [String])
}

class PriceFinder: NSObject {
    
    var prices: [String] = [String]()
    
    weak var priceDelegate: PriceFinderDelegate?
    
    struct initialRequestJSON: Decodable{ //struct for the initial JSON parsing
        let job_id: String
    }
    
    struct checkingRequest: Decodable{
        let job_id: String
        let status: String
    }
    
    struct returnJSON: Decodable{
        let results:[Information]
    }
    
    struct Information: Decodable{
        let content: Content
    }
    
    struct Content: Decodable{
        let url: String
        let offers: [Offers]
    }
    
    struct Offers: Decodable {
        let price: String
        let shop_name: String
        let url: String
    }
    
    func getBestPrices(_ barcode: String){
        let base = "https://api.priceapi.com/v2/jobs/"
        
        let url = URL(string: base)
        let initialRequest = NSMutableURLRequest(url: url!)
        let initialSession = URLSession.shared
        let fields = "token=IZSVNVFBCNHRBVHLOVVECMFFEYEFVFWQKSXZOVWIYYZOLEUJUQZPEKVWIJHXFPMB&source=google_shopping&country=us&topic=product_and_offers&key=gtin&values=" + barcode
        initialRequest.httpBody = fields.data(using: String.Encoding.utf8)
        initialRequest.httpMethod = "POST"
        let initialTask = initialSession.dataTask(with: initialRequest as URLRequest) { (data, response, error) in
            if let response = response{
                print(response)
            }
            
            guard let data = data else {return}
            do{
                let requestJSON = try JSONDecoder().decode(initialRequestJSON.self, from: data) //make json parsing easy
                self.checkStatus(requestJSON.job_id, baseUrl: base) //once the request is sent, gets job_id from JSON and passes it to another function
            }catch{
                print("Error")
            }
        }
        initialTask.resume()
        
    }
    //the function that I'm using to check if the job is done running and ready to return
    func checkStatus(_ id: String, baseUrl: String){ //must run this to make sure the job has finished running in order to get the data
        let token = "?token=IZSVNVFBCNHRBVHLOVVECMFFEYEFVFWQKSXZOVWIYYZOLEUJUQZPEKVWIJHXFPMB"
        let statusURL = URL(string: baseUrl + id + token)
        let statusSession = URLSession.shared
        let statusTask = statusSession.dataTask(with: statusURL!) { (data, response, error) in
            if let response = response{
                print(response)
            }
            if let data = data{
                print(data)
                
                do{
                    let checkJSON = try JSONDecoder().decode(checkingRequest.self, from: data)
                    print(checkJSON.status)
                    if(checkJSON.status != "finished"){
                        self.checkStatus(id, baseUrl: baseUrl)
                    }
                    self.getJSON(id, baseUrl: baseUrl)
                }catch{
                    print(error)
                }
            }
        }
        statusTask.resume()
    }
    
    //this function gets the JSON with the data
    func getJSON(_ id: String, baseUrl: String){
        let token = "?token=IZSVNVFBCNHRBVHLOVVECMFFEYEFVFWQKSXZOVWIYYZOLEUJUQZPEKVWIJHXFPMB"
        let downloadURL = URL(string: baseUrl + id + "/download.json" + token)
        let jsonSession = URLSession.shared
        let jsonTask = jsonSession.dataTask(with: downloadURL!) { (data, response, error) in
            if let response = response{
                print(response)
            }
            print(id)
            if let data = data{
                do {
                    let responseJSON = try JSONDecoder().decode(returnJSON.self, from: data)
                    self.prices.append(responseJSON.results[0].content.url)
                    for i in (responseJSON.results[0].content.offers).indices{
                      self.prices.append(responseJSON.results[0].content.offers[i].shop_name)

                        self.prices.append(responseJSON.results[0].content.offers[i].price)
                        self.prices.append(responseJSON.results[0].content.offers[i].url)
                    }
                    self.priceDelegate?.returnPrices(self.prices)

                }catch{
                    print(error)
                }
            }
            
        }
        jsonTask.resume()
    }
}


