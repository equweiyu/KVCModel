# swift JSON解析

[KVCModel](https://github.com/equweiyu/KVCModel)

先看一段JSON数据，这是网络返回的数据

	{
	    "errorCode": "SUCCESS",
	    "message": "",
	    "data": {
	        "dict": {
	            "id": 3,
	            "text": "equweiyu"
	        },
	        "list": [{
	            "headId": 0,
	            "text": "aaa",
	        }, {
	            "headId": 1,
	            "text": "bbb",
	        }, {
	            "headId": 2,
	            "text": "ccc",
	        }, ],
	        "page": 0
	    }
	}


经过封装最后使用的效果

```swift
// JSON 数据
var json:AnyObject?
//NetDataModel 
let netData = json.flatMap(NetDataModel.init)
//[listModel]
let list = (netData?.data?["list"] as? [AnyObject])?.map(listModel.init)
//DataModel
let model = netData?.data.flatMap(DataModel.init)
```

####1. 封装一个JSON解析基类

使用`setValuesForKeysWithDictionary`方法解析，很简单

```swift
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
```
但是要注意`setValuesForKeys` 对 `Int` 不友好 要使用`NSNumber`代替
####2. 创建Model继承于基类

```swift
class NetDataModel:KVCModel {
    var errorCode:String?
    var data:AnyObject?
    var message:String?
}
class DataModel: KVCModel {
    var dict:dictModel?
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
class dictModel: KVCModel {
    var id:NSNumber?
    var text:String?
}
class listModel: KVCModel {
    var headId:NSNumber?
    var text:String?
}
```
如果Model的属性是`KVCModel` 或者`[KVCModel]` 就在 `setValue(_ value: Any?, forKey key: String)` 解析
####3. 使用

解析`NetDataModel`:
	`let netData = json.flatMap(NetDataModel.init)`

解析`[listModel]`:
	`let list = (netData?.data?["list"] as? [AnyObject])?.map(listModel.init)`

解析`DataModel`:
	`let model = netData?.data.flatMap(DataModel.init)`


