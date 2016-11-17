import Foundation

@objc(KVCModel)
class KVCModel: NSObject {
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    convenience init(json: [String:Any]?) {
        self.init()
        json.flatMap(self.setValuesForKeys)
    }
    convenience init(obj:Any?) {
        self.init(json: obj as? [String:Any])
    }
}

extension Data {
    /**
     NSData -> JSON
     */
    func JSONObject() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
}
@objc(NetDataModel)
class NetDataModel:KVCModel {
    var errorCode:String?
    var data:AnyObject?
    var message:String?
}
@objc(DataModel)
class DataModel: KVCModel {
    var dict:DictModel?
    var list:[listModel]?
    var page:NSNumber?
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "dict":
            self.dict = value.flatMap(DictModel.init)
            self.dict = value.flatMap(DictModel.init)
        case "list":
            self.list = (value as? [AnyObject])?.map(listModel.init)
        default:
            super.setValue(value, forKey: key)
        }
    }
}
@objc(dictModel)
class DictModel: KVCModel {
    var id:NSNumber?
    var text:String?
}
@objc(listModel)
class listModel: KVCModel {
    var headId:NSNumber?
    var text:String?
}

// JSON


var json = (try? Data(contentsOf: #fileLiteral(resourceName: "Home.json")))?.JSONObject()

//NetDataModel
let netData = json.flatMap(NetDataModel.init)

//NetDataModel(obj: nil)

//[listModel]
let list = (netData?.data?["list"] as? [AnyObject])?.map(listModel.init)

//DataModel
let model = netData?.data.flatMap(DataModel.init)











