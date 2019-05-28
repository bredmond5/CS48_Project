//PriceFinder.swift

import UIKit
import Foundation

protocol PriceFinderDelegate : class {
    func returnPrices(_ prices: [String])
}

class PriceFinder: NSObject {
    
    var prices: [String] = [String]()
    
    weak var priceDelegate: PriceFinderDelegate?
    
    var finished = false
    var flag = true
    
    struct initialRequestJSON: Decodable{ //struct for the initial JSON parsing
        let job_id: String
    }
    
    struct checkingRequest: Decodable{
        let job_id: String
        let status: String
        let successful: Int
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
    
    func getBestPrices(_ barcode: String, itemName: String){
        print(itemName)
        let base = "https://api.priceapi.com/v2/jobs/"
        
        let url = URL(string: base)
        let initialRequest = NSMutableURLRequest(url: url!)
        let initialSession = URLSession.shared
        let fields = "token=VPGBCERPAARKAURMZUOFVFSJCADQPRRKYXVXJDPHWRNKKRKUEZMMCHAWILLPGMVQ&source=google_shopping&country=us&topic=product_and_offers&key=gtin&values=" + barcode
        initialRequest.httpBody = fields.data(using: String.Encoding.utf8)
        initialRequest.httpMethod = "POST"
        let initialTask = initialSession.dataTask(with: initialRequest as URLRequest) { (data, response, error) in
            guard let data = data else {return}
            do{
                let requestJSON = try JSONDecoder().decode(initialRequestJSON.self, from: data) //make json parsing easy
                self.checkStatus(requestJSON.job_id, baseUrl: base, barcode: barcode, itemName: itemName)
            }catch{
                print("Error getBestPrice")
            }
        }
        initialTask.resume()
        
    }
    //the function that I'm using to check if the job is done running and ready to return
    func checkStatus(_ id: String, baseUrl: String, barcode: String, itemName: String){ //must run this to make sure the job has finished running in order to get the data
        let token = "?token=VPGBCERPAARKAURMZUOFVFSJCADQPRRKYXVXJDPHWRNKKRKUEZMMCHAWILLPGMVQ"
        let statusURL = URL(string: baseUrl + id + token)
        let statusSession = URLSession.shared
        let statusTask = statusSession.dataTask(with: statusURL!) { (data, response, error)
            in
            if let data = data{
                do{
                    let checkJSON = try JSONDecoder().decode(checkingRequest.self, from: data)
                    print(checkJSON.status)
                
                    if(checkJSON.status != "finished"){
                        self.checkStatus(id, baseUrl: baseUrl, barcode: barcode, itemName: itemName)
                    }
                    else{
                        self.getJSON(id, baseUrl: baseUrl, barcode: barcode, checkSuccess: checkJSON.successful, itemName: itemName)
                    }
                    
                }catch{
                    print("Error checkStatus")
                    self.checkStatus(id, baseUrl: baseUrl, barcode: barcode, itemName: itemName)
                    print("after call")
                }
            }
        }
        statusTask.resume()
        
    }
    
    //this function gets the JSON with the data
    func getJSON(_ id: String, baseUrl: String, barcode: String, checkSuccess: Int, itemName: String){
        print(barcode)
        let fixedSearchName = itemName.replacingOccurrences(of: " ", with: "+")
        if(checkSuccess == 0){ //if the API fails to retrieve a JSON (potentially because barcode is not the appropriate length meaning it cannot search), then we will simply create a link to the item based off of the item name so that way we avoid not showing anything or having an infinite search loop
            self.prices.append("https://www.google.com/search?tbm=shop&hl=en&source=hp&biw=&bih=&q=" + fixedSearchName + "&oq=" + fixedSearchName + "&gs_l=products-cc.3...1173.1173.0.1942.1.1.0.0.0.0.7.7.1.1.0....0...1ac.2.34.products-cc..1.0.0.az1Q1kQyBq8")
            if !self.finished {
                self.priceDelegate?.returnPrices(self.prices)
                self.finished = true
            }
        }else{
            let token = "?token=VPGBCERPAARKAURMZUOFVFSJCADQPRRKYXVXJDPHWRNKKRKUEZMMCHAWILLPGMVQ"
            let downloadURL = URL(string: baseUrl + id + "/download.json" + token)
            let jsonSession = URLSession.shared
            let jsonTask = jsonSession.dataTask(with: downloadURL!) { (data, response, error) in
                guard let data = data else {return}
                do {
                    let responseJSON = try JSONDecoder().decode(returnJSON.self, from: data)
                    print(responseJSON)
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
                    
                    if !self.finished && self.flag {
                        self.priceDelegate?.returnPrices(self.prices)
                        self.finished = true
                    }
                    
                }catch{
                    print("Error getJSON")
                    self.getBestPrices(barcode, itemName: itemName)
                }
            }
            jsonTask.resume()
        }
    }
        
}


