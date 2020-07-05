# JsonMapper

可以一行代码实现json与model的互相转换，还可以使用propertyWrapper来进行自定义操作



### support

swift5.1+, iOS7.0+



## 简单演示

Model遵循JsonMapper即可，支持class与struct

```swift
struct Dog: JsonMapper {
    var name: String = ""
    var age: Int = 0
}

class Dog: JsonMapper {
    var name: String = ""
    var age: Int = 0
    required init() {}
}

let json: [String:Any] = ["name" : "旺财", "age" : 2]

// mapping struct
let dog = Dog.mapping(json)

// mapping class
let dog = Dog.mapping(json)

// maping JsonArray
let jsonArray: [[String:Any]] = [["name" : "旺财", "age" : 2],["name" : "二哈", "age" : 1]]
let dogArray:[Dog] = Dog.mapping(jsonArray)

// to Json
let json = dog.toJson()
let jsonData = dog.toJsonData()
let jsonString = dog.toJsonString()
```



## 属性支持

swift：Bool/(U)Int(8,16,32,64)/Float/Double/Optional/Array/Dictionary/Decimal/Date/Data/URL

objc： CGFLoat/NSString/NSNumber/NSArray/NSDictionary/NSDate/NSData/NSURL

### Bool/Int

额外支持 字符串"TRUE"、"true"、"YES"、"FALSE"、"false"、 "no"、 "1"、 "0"、 "nil"、"null"转换成整数。

JsonMapper完成了Int(int8,16...)/Bool/Float(Double/CGFloat)/String四种类型之间的互相转换，例如即使您的属性类型是Int，json中对应的数据是Float/String... 依然可以完成转换。

### Optional

JsonMapper支持将json中的数据转换成可选类型

```swift
struct Dog: JsonMapper {
    var color: Int???
}
```

即使再多层的可选也可以支持

### 枚举

普通的枚举类型不支持直接转换，需要枚举具备原始值，并且遵循JsonProperty协议才可以转换

```swift
enum Color: String, JsonProperty{
    case red = "red"
    case yellow = "yellow"
    case blue = "blue"
}

struct Dog: JsonMapper {
    var color: Color = .red
}
```

### Array

```swift
struct Person: JsonMapper {
  var dogs: [Dog] = [] 
}
```

只需要在数组中声明元素的类型，并且该元素也遵循JsonMapper协议即可成功转换



### Date/NSDate

默认只支持jsonVal作为since1970的时间戳转换成Date，如果您有一个字符串想转换成Date，请参考PropertyWrapper部分日期高级操作



### Data/NSData

支持将String类型的jsonVal进行utf8编码转换成Data



### String/NSString

支持所有的number类型转成成String，支持Dictionary/Array类型转换成json string



### 泛型

```swift
struct Person<T>: JsonMapper {
  var dogs: [Dog] = [] 
  var name: T?
}

let p = Person<Double>.mapping(json)
```

JsonMapper支持泛型

#### 注意

JsonMapper会将json中的数据进行合适的转换后再对属性进行赋值，查看能否成功转换成对应属性的类型，如果不能成功转换，则不做任何操作，不会影响属性的初始值。 例如：

```swift
enum Color: String, JsonMapperProperty{
    case red = "red"
    case yellow = "yellow"
    case blue = "blue"
}

struct Dog: JsonMapper {
    var color: Color = .red
}

let json: [String:Any] = ["color": "green"]
let dog = Dog.mapping(json)
```

即使color字段转换失败了，但dog.color会仍然==.red 



## 使用PropertyWrapper

使用JsonMapper提供的propertyWrapper可以完成一些自定义的操作

### 属性忽略

```swift
struct Dog: JsonMapper {
    @JsonIgnore var name: String = ""
    var age: Int = 0
}
```

使用@JsonIgnore这个wrapper可以直接忽略这个属性的转换



### 日期转换

JsonMapper只支持将jsonVal作为since1970的时间戳转换成Date/NSDate类型，如果您有一个String字符串想转换成Date，因为date string有不同的format，您可以使用日期包装器指定您的format来解决这个问题。

```swift
struct Dog: JsonMapper {
  var name: String = ""
  @JsonDate("yyyy-MM-dd") var age: Date = Date()
}

let json:[String:Any] = ["age":"2020-07-01"]
```



### 属性映射

```swift
struct Dog: JsonMapper {
    @JsonField("dogName") var name: String = ""
    var age: Int = 0
}
```

有的时候可能json中的字段名称与我们的属性名称不一致，但我们仍然让我们的属性想匹配那个字段，这个时候直接使用@JsonField指定字段名就可以了。

#### keypath

除此之外JsonField还支持keypath映射，以`.`分割即可，例：

@JsonField("info.hsq.dogName") var name: String = ""  则会从info中取hsq再取dogName给属性name赋值



### 属性自定义转换

```swift
struct Dog: JsonMapper {
  @JsonTransform({ jsonVal in
     return "二哈"
  })
  var name: String = ""
  var age: Int = 0
}
```

当框架提供的转换功能不能满足您的需求时，您还可以直接进行自定义转换操作，@JsonTransform可以直接指定一个自定义的转换闭包来处理原始的json数据，在闭包中您必须返回与属性相同的类型。例如name属性为String，闭包的返回值也必须是String



### @JsonField叠加使用

```swift
struct Dog: JsonMapper {
  @JsonField("dogName") @JsonTransform({ jsonVal in
     return "二哈"
  })
  var name: String = ""
  
  @JsonField("dogAge") @JsonDate("yyyy-MM-dd") var age: Date = Date()
}
```

@JsonField是可以叠加使用的，当你既想修改属性对应的jsonfield又进行其他操作的时候，只需要将@JsonField放在最前面即可

