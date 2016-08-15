
import Foundation



extension String {
    
    func substringToIndex(to:Int) -> String {
        return self.substringToIndex(self.startIndex.advancedBy(to, limit: self.endIndex))
    }
    func substringFromIndex(from:Int) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(from, limit: self.endIndex))
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.startIndex.advancedBy(r.startIndex, limit: self.endIndex)
        let end = self.startIndex.advancedBy(r.endIndex, limit: self.endIndex)
        return self[start..<end]
    }
    
    subscript (n:Int) -> String {
        return self[n...n]
    }
    subscript (str:String) -> Range<Index>? {
        return self.rangeOfString(str)
    }
    
    var length: Int {
        return self.characters.count
    }
    
}

extension String {
    /**
     匹配正则表达式 与
     */
    func isMatchAllRegularExpression(patterns:[String]) -> Bool {
        return !patterns.contains({!self.isMatchRegularExpression($0)})
    }
    /**
     匹配正则表达式 或
     */
    func isMatchEitherRegularExpression(patterns:[String]) -> Bool {
        return patterns.contains({self.isMatchRegularExpression($0)})
    }
    /**
     匹配正则表达式
     */
    func isMatchRegularExpression(pattern:String) -> Bool {
        return rangeOfString(pattern,options: .RegularExpressionSearch) != nil
    }
}



@objc(KVCModel)
class KVCModel: NSObject {
    
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    override func setValue(value: AnyObject?, forKey key: String) {
        
        let m = Mirror(reflecting: self)
        m.children
            .filter({$0.label == key})
            .map({Mirror(reflecting: $0.value)})
            .forEach { (mm) in
                
                var str = String(mm.subjectType)
                
                if str.isMatchRegularExpression("^Optional<.*>$") {
                    str = str.substringToIndex(str.length - 1).substringFromIndex("^Optional<".length - 1)
                }
                
                if str.isMatchRegularExpression("^Array<.*>$") {
                    let cname = str.substringToIndex(str.length - 1).substringFromIndex("^Array<".length - 1)
                    
                    if ["NSNumber","String","AnyObject"].contains(cname) {
                        super.setValue(value, forKey: key)
                        return
                    }else if let sclass = NSClassFromString(cname) as? KVCModel.Type {
                        let v = (value as? [AnyObject])?.map(sclass.init)
                        super.setValue(v, forKey: key)
                        return
                    }
                    
                }else {
                    if ["NSNumber","String","AnyObject"].contains(str) {
                        super.setValue(value, forKey: key)
                        return
                    }else {
                        let cname = str
                        
                        if let sclass = NSClassFromString(cname) as? KVCModel.Type {
                            let v = value.flatMap(sclass.init)
                            
                            super.setValue(v, forKey: key)
                            
                            return
                            
                        }
                        
                    }
                    
                }
        }
    }
    
    required override init(){}
    
    
    required convenience init(json: [String:AnyObject]?) {
        self.init()
        json.flatMap(self.setValuesForKeysWithDictionary)
    }
    required convenience init(obj:AnyObject?) {
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
@objc(NetDataModel)
class NetDataModel:KVCModel {
    var errorCode:String?
    var data:AnyObject?
    var message:String?
}

@objc(DataModel)
class DataModel: KVCModel {
    var dict:dictModel?
    var list:[listModel]?
    var page:NSNumber?
}
@objc(dictModel)
class dictModel: KVCModel {
    var id:NSNumber?
    var text:String?
}
@objc(listModel)
class listModel: KVCModel {
    var headId:NSNumber?
    var text:String?
}


// JSON
var json = NSData(contentsOfURL: [#FileReference(fileReferenceLiteral: "Home.json")#])?.JSONObject()
//NetDataModel
let netData = json.flatMap(NetDataModel.init)




//[listModel]
let list = (netData?.data?["list"] as? [AnyObject])?.map(listModel.init)


//DataModel

let data = netData?.data


let model = data.flatMap(DataModel.init)

