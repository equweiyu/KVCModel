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




let jsondata = ["name":"equweiyu"]

@objc(KVCModel)
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
    
    
    func demo(str:String) {
        
    }
    
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

//NetDataModel(obj: nil)

//[listModel]
let list = (netData?.data?["list"] as? [AnyObject])?.map(listModel.init)

//DataModel
let model = netData?.data.flatMap(DataModel.init)



let str1 = "Optional<Array<listModel>>"
let str2 = "Array<listModel>"
let str3 = "Optional<NSNumber>"


indirect enum PType {
    case Optional(type:PType)
    case Array(type:PType)
    case Other(name:String)
}



func getPType(str:String) -> PType{
    if str.isMatchRegularExpression("^Optional<.*>$") {
        let ss = str.substringToIndex(str.length - 1).substringFromIndex("^Optional<".length - 1)
        
        return PType.Optional(type: getPType(ss))
    }else if str.isMatchRegularExpression("^Array<.*>$") {
        let ss = str.substringToIndex(str.length - 1).substringFromIndex("^Array<".length - 1)
        
        return .Array(type: getPType(ss))
    }else {
        
        return .Other(name: str)
    }
}
getPType(str1)








