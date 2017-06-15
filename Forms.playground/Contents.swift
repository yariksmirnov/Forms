//: Playground - noun: a place where people can play

import UIKit
import Forms
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class SwiftObject {
    
    class func method() {
        print(type(of: self))
    }
    
    func schedule() {
        
    }
    
    func doWork() {
        type(of: self).method()
    }
    
}

class Object: SwiftObject {
    
    override class func method() {
        print("BlaBla")
    }
    
}

var obj = SwiftObject()
obj.doWork()

var obj1 = Object()

obj1.doWork()

let string =
    "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}" +
    "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
    "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
    "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
    "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
    "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
    "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

print(string)

