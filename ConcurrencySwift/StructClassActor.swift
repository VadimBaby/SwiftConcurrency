//
//  StructClassActor.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 28.09.2023.
//

import SwiftUI


/*
 
 
 VALUE TYPES:
 
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of data is created
 
 
 REFERENCE TYPES:
 
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread safe
 - When you assign or pass reference type a new reference to original instance will be created (pointer)
 
 ---------------------
 
 STACK:
 - Stores Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has it's own stack!
 
 HEAP:
 - Stores Reference types
 - Shared across threads!
 
 -----------------------
 
 STRUCT:
 - Based on VALUES
 - Can me mutated
 - Stored in the Stack!
 
 CLASS:
 - Based on REFERENCES (INSTANCES)
 - Stored in the Heap!
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 
 -----------------------
 
 Structs: Data Models, Views
 Classes: ViewModels
 Actors: Shared 'Manager and 'Data Store'
 
 */

struct StructClassActor: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear{
                runTest()
            }
    }
}

struct MyStruct {
    var title: String
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    private func runTest() {
        print("Test Started\n")
//        structTest1()
//        
//        printDivider()
//        
//        classTest1()
        
        structTest2()
        
        printDivider()
        
        classTest2()
    }
    
    private func structTest1() {
        print("structTest1:")
        
        let objectA = MyStruct(title: "Starting Title!")
        print("objectA:", objectA.title)
        
        print("Pass the VALUES of objectA to objectB")
        var objectB = objectA
        print("objectB:", objectB.title)
        
        print("objectB title changed")
        objectB.title = "Second Title!"
        
        print("objectA: ", objectA.title)
        print("objectB:", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        
        let objectA = MyClass(title: "Starting Title!")
        print("objectA:", objectA.title)
        
        print("Pass the REFERENCE of objectA to objectB")
        let objectB = objectA
        print("objectB:", objectB.title)
        
        objectB.title = "Second Title!"
        print("objectB title changed")
        
        print("objectA:", objectA.title)
        print("objectB:", objectB.title)
        
        objectA.title = "Third Title!"
        print("objectA title changed")
        
        print("objectA:", objectA.title)
        print("objectB:", objectB.title)
    }
    
    private func actorTest1() {
        Task {
            print("actorTest1")
            
            let objectA = MyActor(title: "Starting Title!")
            await print("ObjectA:", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB")
            let objectB = objectA
            await print("objectB:", objectB.title)
            
            await objectB.updateTitle(newTitle: "Second Title!")
            print("objectB title changed")
            
            await print("objectA:", objectA.title)
            await print("objectB:", objectB.title)
        }
    }
    
    private func printDivider() {
        print("\n\n------------------------\n\n")
    }
}


// Immutable struct (means that this struct got only let properties)
struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> CustomStruct {
        return CustomStruct(title: newTitle)
    }
}

struct MutatingStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    private func structTest2() {
        print("structTest2:")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1:", struct1.title)
        struct1.title = "Title2" // we changed object inside in struct1
        print("Struct1:", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2:", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("Struct2:", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1") // best way
        print("Struct3:", struct3.title)
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3:", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4:", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4:", struct4.title)
    }
}

class MyClass2 {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass2(title: "Title1")
        print("Class1", class1.title)
        class1.title = "Title2" // we changed value of the title inside this instance if this object
        print("Class1", class1.title)
        
        let class2 = MyClass2(title: "Title1")
        print("Class2", class2.title)
        class2.updateTitle(newTitle: "Title2")
        print("Class1", class2.title)

    }
}

#Preview {
    StructClassActor()
}
