//
//  Observable.swift
//  Forms
//
//  Created by Yaroslav Smirnov on 16/06/2017.
//  Copyright © 2017 Yaroslav Smirnov. All rights reserved.
//

import Foundation

public final class Observable<T> {
    
    public var value: T {
        didSet {
            handlers.forEach { $0(oldValue, value) }
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public typealias ChangeHandler = (T, T) -> Void
    
    var handlers = [ChangeHandler]()
    
    public func subscribe(handler: @escaping ChangeHandler) {
        handlers.append(handler)
    }
}
