import AVFoundation
import Foundation

protocol KeywordFinderDelegate : class {
    func returnKeywords(_ keywords: [String])
}

protocol KeywordErrorDelegate: class {
    func error() 
}

class KeywordFinder {
    
    weak var keywordDelegate: KeywordFinderDelegate?
    weak var errorDelegate: KeywordErrorDelegate?
    
    struct responseJSON: Decodable{
        let response: responseType
    }
    
    struct responseType: Decodable{
        let entities: [Content]
    }
    
    struct Content: Decodable{
        let entityId: String
    }
    
    var flag = true
    var finished = false
    
    func truncateName(_ itemN: String) {
        //DispatchQueue.main.async {
        let urlString = "https://api.textrazor.com/"
        let headers = [
            "x-textrazor-key" : "55864c94efce2b09deef214d17c8de7f0eeb73573655571c5ca9125b"
        ]
        var z : [String] = []
        let x : String = "text=" + itemN
        let y : String = x + "&extractors=entities"
        let postData = NSMutableData(data: y.data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 1.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        print("Before Session")
        let task = URLSession.shared.dataTask(with: request as URLRequest){ (data, response, error) in
            if let data = data{
                do{
                    print("INSIDE SESSION")
                    let JSONinfo = try JSONDecoder().decode(responseJSON.self, from: data)
                    for i in (JSONinfo.response.entities).indices{
                        if  !(z.contains(JSONinfo.response.entities[i].entityId)) && (JSONinfo.response.entities[i].entityId != ""){
                            z.append(JSONinfo.response.entities[i].entityId)
                            print(z)
                        }
                    }
                    DispatchQueue.main.async {
                        if(self.flag) {
                            self.finished = true
                            self.keywordDelegate?.returnKeywords(z)
                        }
                    }
                }catch{
                    print("truncate Name error")
                    print(error)
                    self.errorDelegate?.error()
                }
            }else{
                print("truncate name error")
                self.errorDelegate?.error()
            }
        }
        task.resume()
    }
}
