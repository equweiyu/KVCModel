import Foundation

let jsondata = ["name":"equweiyu"]

class KVCModel: NSObject {
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
    
    }
    override func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    convenience init(json: [String:AnyObject]?) {
        self.init()
        json.flatMap(self.setValuesForKeysWithDictionary)
    }
    convenience init(obj:AnyObject?) {
        self.init(json: obj as? [String:AnyObject])
    }
}

extension NSData {
    /**
     NSData -> JSON
     */
    func JSONObject() -> AnyObject? {
        return try? NSJSONSerialization.JSONObjectWithData(self, options: [])
    }
}
class NetDataModel:KVCModel {
    var errorCode:String?
    var data:AnyObject?
    var message:String?
}

class DataModel: KVCModel {
    var dict:dictModel?
    var list:[listModel]?
    var page:NSNumber?
    
    override func setValue(value: AnyObject?, forKey key: String) {
        switch key {
        case "dict":
            self.dict = value.flatMap(dictModel.init)
        case "list":
            self.list = (value as? [AnyObject])?.map(listModel.init)
        default:
            super.setValue(value, forKey: key)
        }
    }
}

class dictModel: KVCModel {
    var id:NSNumber?
    var text:String?
}
class listModel: KVCModel {
    var headId:NSNumber?
    var text:String?
}
// JSON
var json = NSData(contentsOfURL: [#FileReference(fileReferenceLiteral: "Home.json")#])?.JSONObject()
//NetDataModel
let netData = json.flatMap(NetDataModel.init)

//NetDataModel(obj: nil)

//[listModel]
let list = (netData?.data?["list"] as? [AnyObject])?.map(listModel.init)
//DataModel
let model = netData?.data.flatMap(DataModel.init)
