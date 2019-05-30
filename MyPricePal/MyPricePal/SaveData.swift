
import CoreData
import UIKit

class SaveData {
    static func getData() -> [SearchStruct] {
        var arr = [SearchStruct]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let searchStruct = SearchStruct(barcodeString: data.value(forKey: "barcodeString") as! String, itemN: data.value(forKey: "itemN") as! String, keywordString: data.value(forKey: "keywordString") as! [String], priceArray: data.value(forKey: "priceArray") as! [String])
                arr.append(searchStruct)
            }
        } catch {
            print("Failed getting data")
        }
        return arr
    }
    
    static func saveData(_ items: [SearchStruct]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Items", in: context)
        
        for item in items {
            let newItem = NSManagedObject(entity: entity!, insertInto: context)
            
            newItem.setValue(item.itemN, forKey: "itemN")
            newItem.setValue(item.barcodeString, forKey: "barcodeString")
            newItem.setValue(item.priceArray, forKey: "priceArray")
            newItem.setValue(item.keywordString, forKey: "keywordString")
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    static func deleteData(_ barcodeString: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if(data.value(forKey: "barcodeString") as! String == barcodeString) {
                    context.delete(data)
                }
            }
        }catch {
            print("Delete data failed")
        }
    }
    
    static func deleteAllData(_ entity:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
               context.delete(data)
            }
        } catch {
            print("Failed getting data")
        }
    }
    
    static func deleteAllData2(_ entity: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        let context = appDelegate.persistentContainer.viewContext
        do { try context.execute(DelAllReqVar) }
        catch { print(error) }
    }
}
