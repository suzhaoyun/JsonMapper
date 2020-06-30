# JsonMapper

一行代码实现json与obj的互相转换，还可以使用propertyWrapper来进行自定义操作



## 使用方法

只遵循JsonMapper即可，支持class与struct



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
```



## 支持属性类型

boo/Int8/Int32/Int64/Int/Optional/Array/Dictionary

### Bool/Int

额外支持 字符串"TRUE"、"true"、"YES"、"FALSE"、"false"、 "no"、 "1"、 "0"、 "nil"、"null"转换成bool



### Optional

JsonMapper支持将json中的数据转换成可选类型

```swift
struct Dog: JsonMapper {
    var color: Int???
}
```

即使再多层的可选也可以支持



### 枚举

枚举不支持直接转换，需要枚举具备原始值，并且遵循JsonMapperProperty协议才可以转换

```swift
enum Color: String, JsonMapperProperty{
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



#### 注意

JsonMapper会将json中的数据进行合适的转换，看能否转换成对应属性的类型，如果实在不能转换成功，则不做任何操作，不会影响属性的初始值。 例如：

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



## 自定义操作

使用JsonMapper提供的propertyWrapper可以完成一些自定义的操作

### 属性忽略

```swift
struct Dog: JsonMapper {
    @JsonIgnore var name: String = ""
    var age: Int = 0
}
```

使用@JsonIgnore这个wrapper可以直接忽略这个属性的转换

### 属性名替换

```swift
struct Dog: JsonMapper {
    @JsonField("dogName") var name: String = ""
    var age: Int = 0
}
```

有的时候可能json中的字段名称与我们的属性名称不一致，但我们仍然想匹配那个字段，这个时候直接使用@JsonField就可以了

### 自定义转换

```swift
struct Dog: JsonMapper {
  @JsonTransfrom({ jsonVal in
     return "二哈"
  })
  var name: String = ""
  var age: Int = 0
}
```

当框架提供的转换功能实在不能满足您的需求时，您还可以直接进行自定义转换操作，@JsonTransfrom可以直接指定一个自定义的转换闭包来处理原始的json数据，在闭包中您必须返回与属性相同的类型。例如name属性为String，闭包的返回值也必须是String

### 日期

JsonMapper不支持直接转换Date/NSDate类型，因为date有不同的format，但您可以使用包装器来解决这个问题。

```swift
struct Dog: JsonMapper {
  var name: String = ""
  @JsonDate var age: Date = Date()
  @JsonDate("yyyy-MM-dd") var age1: Date = Date()
}
```

@JsonDate可以指定日期的format

@JsonDate 默认的format是yyyy-MM-dd HH:mm:ss 

如果json数据不是String类型时，会将json数据转换成TimeInterval来创建Date



### 包装器叠加

@JsonField是可以叠加使用的  

```swift
struct Dog: JsonMapper {
  @JsonField("dogName")
  @JsonTransfrom({ jsonVal in
     return "二哈"
  })
  var name: String = ""
  
  @JsonField("dogAge") @JsonDate("yyyy-MM-dd") var age: Date = Date()
}
```

