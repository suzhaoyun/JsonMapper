# JsonMapper

一行代码实现json与obj的互相转换，还可以使用swift5.1的propertyWrapper进行自定义操作



## 使用方法

遵循JsonMapper即可，支持class与struct

### 简单演示

```swift
struct Dog: JsonMapper {
    var name: String = ""
    var age: Int = 0
}

class Dog: JsonMapper {
    var name: String = ""
    var age: Int = 0
}

let json: [String:Any] = ["name" : "旺财", "age" : 2]

// mapping struct
let dog = Dog.mapping(json)

// mapping class
let dog = Dog.mapping(json)

// to json
let json = dog.toJson()

// to jsonData
let data = dog.toJsonData()

// to jsonString
let str = dog.toJsonString()
```



## 支持属性类型

boo/Int8/Int32/Int64/Int/Optional/Array/Dictionary



## 高级用法

使用JsonMapper提供的propertyWrapper

### 属性忽略

```swift
struct Dog: JsonMapper {
    @JsonMapperIgnore var name: String = ""
    var age: Int = 0
}
```

使用*@JsonMapperIgnore*这个wrapper可以直接忽略这个属性的转换

### 属性替换

```swift
struct Dog: JsonMapper {
    @JsonMapperConfig(name: "dogName") var name: String = ""
    var age: Int = 0
}
```

有的时候我们需要匹配的字段不与属性名相同，使用*@JsonMapperConfig*指定name来实现

### 自定义转换

```swift
struct Dog: JsonMapper {
  @JsonMapperConfig(mapper: { jsonVal in
     return "二哈"
  })
  var name: String = ""
  var age: Int = 0
}
```

当提供的转换功能不能满足您的需求时，*@JsonMapperConfig*可以指定一个自定义的mapper自行处理原始的json数据，在mapper中您必须返回与属性相同的类型 例如name属性为String，mapper闭包的返回值也必须是String

