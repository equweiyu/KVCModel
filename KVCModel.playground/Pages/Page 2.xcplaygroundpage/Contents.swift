
import Foundation

extension String {
    
    func substring(to:Int) -> String {
        return self.substring(to: self.index(self.startIndex, offsetBy: to, limitedBy: self.endIndex) ?? self.endIndex)
    }
    func substring(from:Int) -> String {
        return self.substring(from: self.index(self.startIndex, offsetBy: from, limitedBy: self.endIndex) ?? self.endIndex)
    }
    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound, limitedBy: self.endIndex) ?? self.endIndex
        let end = self.index(self.startIndex, offsetBy: r.upperBound, limitedBy: self.endIndex) ?? self.endIndex
        return self[start..<end]
    }
    subscript (n:Int) -> String {
        return self[n..<n+1]
    }
    subscript (str:String) -> Range<Index>? {
        return self.range(of: str)
    }
    var length: Int {
        return self.characters.count
    }
    func match(regularExpression:String) -> Bool {
        return range(of: regularExpression,options: .regularExpression) != nil
    }
}


//@objc(KVCReflectModel)
class KVCReflectModel: NSObject {
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    override func setValue(_ value: Any?, forKey key: String) {
        
        Mirror(reflecting: self).children
            .filter({$0.label == key})
            .forEach { (chird) in
                
                var str = String(describing: Mirror(reflecting: chird.value).subjectType)
                if str.match(regularExpression: "^Optional<.*>$") {
                    str = str.substring(to:str.length - 1).substring(from:"^Optional<".length - 1)
                }
//                if ["Int","Double","Float","NSInteger","Bool"].contains(str) && String(chird.value) == "nil" {
//                    assertionFailure("\(key):\(str) 是基础类型需要初始化 ")
//                }

                if str.match(regularExpression:"^Array<.*>$") {
                    let cname = str.substring(to:str.length - 1).substring(from:"^Array<".length - 1)
                    if let sclass = NSClassFromString(cname) as? KVCReflectModel.Type {
                        let v = (value as? [Any])?.map(sclass.init)
                        super.setValue(v, forKey: key)
                    }else {
                        super.setValue(value, forKey: key)
                    }
                }else {
                    let cname = str
                    if let sclass = NSClassFromString(cname) as? KVCReflectModel.Type {
                        let v = value.flatMap(sclass.init)
                        super.setValue(v, forKey: key)
                    }else {
                        super.setValue(value, forKey: key)
                    }
                }
        }
        
        Mirror(reflecting: self).children
            .filter({$0.label == key})
            .filter({(value != nil && String(describing: $0.value) == "nil")})
            .forEach { _ in
                print("\(key)解析失败")
        }
    }
    
    override init(){
        super.init()
    }
    convenience init(json: [String:Any]?) {
        self.init()
        json.flatMap(self.setValuesForKeys)
    }
    required convenience init(obj:Any?) {
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
//@objc(NetDataModel)
class NetDataModel:KVCReflectModel {
    var errorCode:String?
    var data:Any?
    var message:String?
}

//@objc(DataModel)
class DataModel: KVCReflectModel {
    var dict:dictModel?
    var list:NSInteger = 0
    var page:NSNumber?
}

@objc(dictModel)
class dictModel: KVCReflectModel {
    var id:NSNumber?
    var text:String?
}



// JSON
var json = (try? Data(contentsOf: #fileLiteral(resourceName: "H.json")))?.JSONObject()

//NetDataModel
let netData = json.flatMap(NetDataModel.init)

//DataModel
let data = netData?.data

let model = data.flatMap(DataModel.init)
model?.dict?.id

