//PriceFinder.swift

import UIKit
import Foundation

protocol PriceFinderDelegate : class {
    func returnPrices(_ prices: [String])
}

class PriceFinder: NSObject {
    
    var prices: [String] = [String]()
    
    weak var priceDelegate: PriceFinderDelegate?
    
    var sent = false
    
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
        let url: String? = ""
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
            guard let data = data else {return}
            do{
                let requestJSON = try JSONDecoder().decode(initialRequestJSON.self, from: data) //make json parsing easy
                self.checkStatus(requestJSON.job_id, baseUrl: base, barcode: barcode) //once the request is sent, gets job_id from JSON and passes it to another function
            }catch{
                print("Error getBestPrice")
            }
        }
        initialTask.resume()
        
    }
    //the function that I'm using to check if the job is done running and ready to return
    func checkStatus(_ id: String, baseUrl: String, barcode: String){ //must run this to make sure the job has finished running in order to get the data
        var count = 0
        let token = "?token=IZSVNVFBCNHRBVHLOVVECMFFEYEFVFWQKSXZOVWIYYZOLEUJUQZPEKVWIJHXFPMB"
        let statusURL = URL(string: baseUrl + id + token)
        let statusSession = URLSession.shared
        let statusTask = statusSession.dataTask(with: statusURL!) { (data, response, error) in
            if let data = data{
                do{
                    let checkJSON = try JSONDecoder().decode(checkingRequest.self, from: data)
                    print(checkJSON.status)
                    if(checkJSON.status != "finished"){
                        self.checkStatus(id, baseUrl: baseUrl, barcode: barcode)
                    }else{
                        count = 1
                    }
                    if(count == 1){
                        self.getJSON(id, baseUrl: baseUrl, barcode: barcode)
                    }
                }catch{
                    print("Error checkStatus")
                }
            }
        }
        statusTask.resume()
    }
    
    //this function gets the JSON with the data
    func getJSON(_ id: String, baseUrl: String, barcode: String){
        print(barcode)
        let token = "?token=IZSVNVFBCNHRBVHLOVVECMFFEYEFVFWQKSXZOVWIYYZOLEUJUQZPEKVWIJHXFPMB"
        let downloadURL = URL(string: baseUrl + id + "/download.json" + token)
        let jsonSession = URLSession.shared
        let jsonTask = jsonSession.dataTask(with: downloadURL!) { (data, response, error) in
            guard let data = data else {return}
            print(data)
            do {
                let responseJSON = try JSONDecoder().decode(returnJSON.self, from: data)
                if((responseJSON.results[0].content.url!) != ""){
                    self.prices.append(responseJSON.results[0].content.url!)
                }else{
                    self.prices.append("https://www.google.com/search?tbm=shop&hl=en&source=hp&biw=&bih=&q=" + barcode + "&oq=" + barcode + "&gs_l=products-cc.3...1173.1173.0.1942.1.1.0.0.0.0.7.7.1.1.0....0...1ac.2.34.products-cc..1.0.0.az1Q1kQyBq8")
                }
                for i in (responseJSON.results[0].content.offers).indices{
                    self.prices.append(responseJSON.results[0].content.offers[i].shop_name)
                    self.prices.append(responseJSON.results[0].content.offers[i].price)
                    self.prices.append(responseJSON.results[0].content.offers[i].url)
                }
                
                if !self.sent {
                    self.priceDelegate?.returnPrices(self.prices)
                    self.sent = true
                }
                
            }catch{
                print("Error getJSON")
            }
        }
        jsonTask.resume()
    }
}


