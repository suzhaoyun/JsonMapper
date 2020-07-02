//
//  Metadatas.cpp
//  JMMetadata
//
//  Created by ZYSu on 2020/7/2.
//  Copyright © 2020 ZYSu. All rights reserved.
//

#import "Metadatas.h"
#import <objc/runtime.h>
#include <string>
/// Non-type metadata kinds have this bit set.
const unsigned MetadataKindIsNonType = 0x400;

/// Non-heap metadata kinds have this bit set.
const unsigned MetadataKindIsNonHeap = 0x200;

// The above two flags are negative because the "class" kind has to be zero,
// and class metadata is both type and heap metadata.

/// Runtime-private metadata has this bit set. The compiler must not statically
/// generate metadata objects with these kinds, and external tools should not
/// rely on the stability of these values or the precise binary layout of
/// their associated data structures.
const unsigned MetadataKindIsRuntimePrivate = 0x100;
/// Kinds of Swift metadata records.  Some of these are types, some
/// aren't.
enum class MetadataKind : uint32_t {
#define METADATAKIND(name, value) name = value,
#define ABSTRACTMETADATAKIND(name, start, end)                                 \
  name##_Start = start, name##_End = end,
#include "MetadataKind.def"

  /// The largest possible non-isa-pointer metadata kind value.
  ///
  /// This is included in the enumeration to prevent against attempts to
  /// exhaustively match metadata kinds. Future Swift runtimes or compilers
  /// may introduce new metadata kinds, so for forward compatibility, the
  /// runtime must tolerate metadata with unknown kinds.
  /// This specific value is not mapped to a valid metadata kind at this time,
  /// however.
  LastEnumerated = 0x7FF,
};
const unsigned LastEnumeratedMetadataKind = (unsigned)MetadataKind::LastEnumerated;

/// Try to translate the 'isa' value of a type/heap metadata into a value
/// of the MetadataKind enum.
inline MetadataKind getEnumeratedMetadataKind(uint64_t kind) {
  if (kind > LastEnumeratedMetadataKind)
    return MetadataKind::Class;
  return MetadataKind(kind);
}


struct Metadata {
    public:
    uintptr_t kind;

    MetadataKind getKind() {
        return getEnumeratedMetadataKind(kind);
    }
};


struct PropertyMetadata: Metadata {
    int getFieldCount(){
        return 1;
    }
};

struct FieldRecord {
    int32_t flags;
    int32_t _mangledTypeName;
    int32_t _fieldName;
    
    const char *getFieldName() {
        intptr_t address = reinterpret_cast<intptr_t>(&_fieldName);
        return (const char *)(_fieldName + address);
    }
    const char *getMangledTypeName() {
        intptr_t address = reinterpret_cast<intptr_t>(&_mangledTypeName);
        return (const char *)(_mangledTypeName + address);
    }
};

struct FieldDescriptor {
    int32_t mangledTypeName;
    int32_t superclass;
    uint16_t _kind;
    uint16_t fieldRecordSize;
    uint32_t numFields;
    struct FieldRecord fieldRecords[];
    struct FieldRecord *getFieldRecords() {
        return (struct FieldRecord *)&fieldRecords;
    }

};

struct TargetContextDescriptor {
    /// Flags describing the context, including its kind and format version.
    uint32_t Flags;

    /// The parent context, or null if this is a top-level context.
    int32_t Parent;

    int32_t getFieldOffsetVectorOffset();

    struct FieldDescriptor *getFieldDescriptor();
};

struct StructDescriptor: TargetContextDescriptor {

    /// The name of the type
    uint32_t name;

    /// A pointer to the metadata access function for this type
    int32_t accessFunctionPtr;

    /// A pointer to the field descriptor for the type, if any
    int32_t fields;

    /// The number of stored properties in the struct. If there is a field offset vector, this is its length
    uint32_t numFields;

    /// The offset of the field offset vector for this struct's stored properties in its metadata, if any. 0 means there is no field offset vector
    int32_t fieldOffsetVectorOffset;

//    let genericContextHeader: TargetTypeGenericContextDescriptorHeader
    int32_t getFieldOffsetVectorOffset() {
        return fieldOffsetVectorOffset;
    }

    struct FieldDescriptor *getFieldDescriptor(){
        void *ptr = &(this->fields);
        intptr_t x = reinterpret_cast<intptr_t>(ptr) + this->fields;
        return reinterpret_cast<struct FieldDescriptor *>(x);
    }
};

struct TargetClassDescriptor: TargetContextDescriptor {
    /// The name of the type
    uint32_t name;

    /// A pointer to the metadata access function for this type
    int32_t accessFunctionPtr;

    /// A pointer to the field descriptor for the type, if any
    int32_t fields;

    /// The type of the superclass, expressed as a mangled type name that can refer to the generic arguments of the subclass type
    int32_t superclassType;

    /// If this descriptor does not have a resilient superclass, this is the negative size of metadata objects of this class (in words)
    uint32_t metadataNegativeSizeInWords;

    /// If this descriptor does not have a resilient superclass, this is the positive size of metadata objects of this class (in words)
    uint32_t metadataPositiveSizeInWords;

    /// The number of additional members added by this class to the class metadata
    uint32_t numImmediateMembers;

    /// The number of stored properties in the class, not including its superclasses. If there is a field offset vector, this is its length.
    uint32_t numFields;

    /// The offset of the field offset vector for this class's stored properties in its metadata, in words. 0 means there is no field offset vector
    uint32_t fieldOffsetVectorOffset;

//    let genericContextHeader: TargetTypeGenericContextDescriptorHeader
    int32_t getFieldOffsetVectorOffset() {
        return fieldOffsetVectorOffset;
    }

    struct FieldDescriptor *getFieldDescriptor(){
        void *ptr = &(this->fields);
        intptr_t x = reinterpret_cast<intptr_t>(ptr) + this->fields;
        return reinterpret_cast<struct FieldDescriptor *>(x);
    }
};
/// Is this a Swift class from the Darwin pre-stable ABI?
/// This bit is clear in stable ABI Swift classes.
/// The Objective-C runtime also reads this bit.
#define IsSwiftPreStableABI 0x1

/// Does this class use Swift refcounting?
#define UsesSwiftRefcounting 0x2

struct ClassMetadata {
    /// The kind. Only valid for non-class metadata; getKind() must be used to get
    /// the kind value.
    intptr_t Kind;

    void *superclass;

    void *cacheData[2];

    intptr_t data;

    /// Swift-specific class flags.
    uint32_t Flags;

    /// The address point of instances of this type.
    uint32_t InstanceAddressPoint;

    /// The required size of instances of this type.
    /// 'InstanceAddressPoint' bytes go before the address point;
    /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
    uint32_t InstanceSize;

    /// The alignment mask of the address point of instances of this type.
    uint16_t InstanceAlignMask;

    /// Reserved for runtime use.
    uint16_t Reserved;

    /// The total size of the class object, including prefix and suffix
    /// extents.
    uint32_t ClassSize;

    /// The offset of the address point within the class object.
    uint32_t ClassAddressPoint;

      // Description is by far the most likely field for a client to try
      // to access directly, so we force access to go through accessors.
//    private:
//      /// An out-of-line Swift-specific description of the type, or null
//      /// if this is an artificial subclass.  We currently provide no
//      /// supported mechanism for making a non-artificial subclass
//      /// dynamically.
    struct TargetClassDescriptor *descriptor;
//      TargetSignedPointer<Runtime, const TargetClassDescriptor<Runtime> * __ptrauth_swift_type_descriptor> Description;
//    uintptr_t Description
//
//    public:
//      /// A function for destroying instance variables, used to clean up after an
//      /// early return from a constructor. If null, no clean up will be performed
//      /// and all ivars must be trivial.
     void *IVarDestroyer;

    bool isSwiftClass() {
        return (this->Flags) & UsesSwiftRefcounting;
    }

public:
    inline uint32_t getFieldCount() {
        return this->descriptor->numFields;
    }

    void getFieldOffsets(int64_t *offsets) {
        if (isSwiftClass()) {
            uint32_t numFields = getFieldCount();
            if (numFields == 0) { return; }
            int32_t offset = this->descriptor->getFieldOffsetVectorOffset();
            if (offset == 0) { return; }
            intptr_t header = reinterpret_cast<intptr_t>(this);
            intptr_t *fieldOffsets = reinterpret_cast<intptr_t *>(header + offset);
            for (int i = 0; i < numFields; i++) {
                offsets[i] = fieldOffsets[i];
            }
        }
        else{
            unsigned int ivarCount = 0;
            Ivar *list = class_copyIvarList((__bridge Class)this, &ivarCount);
            if (ivarCount <= 0) { return; }
            for (int i = 0; i < ivarCount; i++) {
                offsets[i] = ivar_getOffset(list[i]);
            }
        }

    }
    
    int64_t getGenericTypeOffset() {
        // don't have resilient superclass
        if ((0x4000 & Flags) == false) {
            return ((Flags & 0x800) == false) ? (descriptor->metadataPositiveSizeInWords - descriptor->numImmediateMembers) : (-descriptor->metadataNegativeSizeInWords);
        }
        return 0;
    }

};

struct StructMetadata: Metadata {
    /// An out-of-line description of the type
    struct StructDescriptor *descriptor;

public:
    inline uint32_t getFieldCount() {
        return this->descriptor->numFields;
    }
    void getFieldOffsets(int64_t *offsets) {
        int numFields = this->descriptor->numFields;
        if (numFields == 0) { return; }
        int32_t offset = this->descriptor->getFieldOffsetVectorOffset();
        if (offset == 0) { return; }
        int64_t header = reinterpret_cast<int64_t>(this);
        int32_t *fieldOffsets = reinterpret_cast<int32_t *>(header + offset);
        for (int i = 0; i < numFields; i++) {
            offsets[i] = fieldOffsets[i];
        }
    }
    
    int64_t getGenericTypeOffset() {
        return 2;
    }
};
const Metadata * _Nullable
swift_getTypeByMangledNameInContext(
                        const char *typeNameStart,
                        size_t typeNameLength,
                        void  *environment, void *genericArgs);

struct jm_ivar * _Nullable jm_copyIvarList(void *metadata, int *ivar_count) {
    struct Metadata *ptr = (struct Metadata *)metadata;
    MetadataKind kind = ptr->getKind();
    uint32_t ivCount = 0;
    if (kind == MetadataKind::Class) {
        struct ClassMetadata *cptr = (struct ClassMetadata *)ptr;
        ivCount = cptr->getFieldCount();
    }else if (kind == MetadataKind::Struct) {
        struct StructMetadata *sptr = (struct StructMetadata *)ptr;
        ivCount = sptr->getFieldCount();
    }else{
        *ivar_count = 0;
        return nullptr;
    }

    struct jm_ivar *list = (struct jm_ivar *)malloc(sizeof(struct jm_ivar) * ivCount);
    if (list == nullptr) {
        // malloc失败了
        *ivar_count = 0;
        return nullptr;
    }

    int64_t offsets[ivCount];
    struct FieldRecord *fieldRecords;
    int64_t genericTypeOffset = 0;
    void *environment = nullptr;
    if (kind == MetadataKind::Class) {
        struct ClassMetadata *cptr = (struct ClassMetadata *)ptr;
        fieldRecords = cptr->descriptor->getFieldDescriptor()->getFieldRecords();
        genericTypeOffset = cptr->getGenericTypeOffset();
        environment = cptr->descriptor;
    }else {
        struct StructMetadata *sptr = (struct StructMetadata *)ptr;
        sptr->getFieldOffsets(offsets);
        fieldRecords = sptr->descriptor->getFieldDescriptor()->getFieldRecords();
        genericTypeOffset = sptr->getGenericTypeOffset();
        environment = sptr->descriptor;
    }

    intptr_t *header = (intptr_t *)ptr;
    void *genericArgs = (void *)(header + genericTypeOffset);
    
    for (int i = 0; i < ivCount; i++) {
        struct FieldRecord *fieldRecord = fieldRecords + i;
        const char *fieldName = fieldRecord->getFieldName();
        const char *mangledTypeName = fieldRecord->getMangledTypeName();
        std::string str = mangledTypeName;
        printf("%s %s\n", fieldRecord->getFieldName(), fieldRecord->getMangledTypeName());
//        swift_getTypeByMangledNameInContext(mangledTypeName, str.size(), environment, genericArgs);
    }
    return nullptr;
}

//
///// Get the nominal type descriptor if this metadata describes a nominal type,
///// or return null if it does not.
//ConstTargetMetadataPointer<Runtime, TargetTypeContextDescriptor>
//getTypeContextDescriptor() const {
//  switch (getKind()) {
//  case MetadataKind::Class: {
//    const auto cls = static_cast<const TargetClassMetadata<Runtime> *>(this);
//    if (!cls->isTypeMetadata())
//      return nullptr;
//    if (cls->isArtificialSubclass())
//      return nullptr;
//    return cls->getDescription();
//  }
//  case MetadataKind::Struct:
//  case MetadataKind::Enum:
//  case MetadataKind::Optional:
//    return static_cast<const TargetValueMetadata<Runtime> *>(this)
//        ->Description;
//  case MetadataKind::ForeignClass:
//    return static_cast<const TargetForeignClassMetadata<Runtime> *>(this)
//        ->Description;
//  default:
//    return nullptr;
//  }
//}
//
///// Get the class object for this type if it has one, or return null if the
///// type is not a class (or not a class with a class object).
//const TargetClassMetadata<Runtime> *getClassObject() const;
//
///// Retrieve the generic arguments of this type, if it has any.
//ConstTargetMetadataPointer<Runtime, swift::TargetMetadata> const *
//getGenericArgs() const {
//  auto description = getTypeContextDescriptor();
//  if (!description)
//    return nullptr;
//
//  auto generics = description->getGenericContext();
//  if (!generics)
//    return nullptr;
//
//  auto asWords = reinterpret_cast<
//    ConstTargetMetadataPointer<Runtime, swift::TargetMetadata> const *>(this);
//  return asWords + description->getGenericArgumentOffset();
//}
//static constexpr int32_t getGenericArgumentOffset() {
//   return sizeof(TargetEnumMetadata<Runtime>) / sizeof(StoredPointer);
// }
///// Return the start of the generic arguments array in the nominal
// /// type's metadata. The returned value is measured in sizeof(StoredPointer).
// const TargetMetadata<Runtime> * const *getGenericArguments(
//                              const TargetMetadata<Runtime> *metadata) const {
//   auto offset = getGenericArgumentOffset();
//   auto words =
//     reinterpret_cast<const TargetMetadata<Runtime> * const *>(metadata);
//   return words + offset;
// }
//
//  // A convenient macro for defining a getter and setter for a flag.
//  // Intended to be used in the body of a subclass of FlagSet.
//#define FLAGSET_DEFINE_FLAG_ACCESSORS(BIT, GETTER, SETTER) \
//  bool GETTER() const {                                    \
//    return this->template getFlag<BIT>();                  \
//  }                                                        \
//  void SETTER(bool value) {                                \
//    this->template setFlag<BIT>(value);                    \
//  }
//
//
//FLAGSET_DEFINE_FLAG_ACCESSORS(Class_HasResilientSuperclass,
//                              class_hasResilientSuperclass,
//                              class_setHasResilientSuperclass)
