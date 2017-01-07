/*
 * nodekit.io
 *
 * Copyright (c) 2016-7 OffGrid Networks. All Rights Reserved.
 * Portions Copyright 2015 XWebView
 * Portions Copyright (c) 2014 Intel Corporation.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

import ObjectiveC

class NKScriptTypeInfo: CollectionType {
    
    enum Member {
        
        case Method(selector: Selector, arity: Int32)
        
        case Property(getter: Selector, setter: Selector)
        
        case Initializer(selector: Selector, arity: Int32)
        
        var isMethod: Bool {
            
            if case .Method = self { return true }
            
            return false
        }
        
        var isProperty: Bool {
            
            if case .Property = self { return true }
            
            return false
            
        }
        
        var isInitializer: Bool {
            
            if case .Initializer = self { return true }
            
            return false
            
        }
        var selector: Selector? {
            
            switch self {
                
            case let .Method(selector, _):
                
                assert(selector != Selector())
                
                return selector
                
            case let .Initializer(selector, _):
                
                assert(selector != Selector())
                
                return selector
                
            default:
                
                return nil
                
            }
            
        }
        
        var getter: Selector? {
            
            if case .Property(let getter, _) = self {
                
                assert(getter != Selector())
                
                return getter
            }
            
            return nil
            
        }
        
        var setter: Selector? {
            
            if case .Property(let getter, let setter) = self {
                
                assert(getter != Selector())
                
                return setter
                
            }
            
            return nil
            
        }
        
        var type: String {
            
            let promise: Bool
            
            let arity: Int32
            
            switch self {
                
            case let .Method(selector, a):
                
                promise = selector.description.hasSuffix(":promiseObject:") ||
                    selector.description.hasSuffix("PromiseObject:")
                
                arity = a
                
            case let .Initializer(_, a):
                
                promise = false // Initializers no longer default to promise
                
                arity = a < 0 ? a: a + 1
                
            default:
                
                promise = false
                
                arity = -1
                
            }
            
            if !promise && arity < 0 {
                
                return ""
                
            }
            
            return "#" + (arity >= 0 ? "\(arity)" : "") + (promise ? "p" : "a")
            
        }
        
    }
    
    let plugin: AnyClass
    
    private var members = [String: Member]()
    
    private static let exclusion: Set<Selector> = {
        
        var methods = NKInstanceMethods(forProtocol: NKScriptExport.self)
        
        return methods.union([
            
            #selector(_SpecialSelectors.dealloc),
            
            #selector(NSObject.copy as ()->AnyObject)
            
            ])
        
    }()
    
    init(plugin: AnyClass) {
        
        self.plugin = plugin
        
        enumerateExcluding(self.dynamicType.exclusion) {
            (name, member) -> Bool in
            
            var name = name
            
            var member = member
            
            switch member {
                
            case let .Method(selector, _):
                
                if let end = name.characters.indexOf(":") {
                    
                    name = name[name.startIndex ..< end]
                    
                }
                
                if name.characters.first == "_" {
                    
                    return true
                    
                } else if let cls = plugin as? NKScriptExport.Type {
                    
                    if cls.isExcludedFromScript?(selector.description) ?? false {
                        
                        return true
                        
                    }
                    
                    
                    name = cls.rewriteScriptNameForKey?(selector.description) ?? name
                    
                }
                
            case .Property(_, _):
                
                if name.characters.first == "_" {
                    
                    return true
                    
                } else if let cls = plugin as? NKScriptExport.Type {
                    
                    if cls.isExcludedFromScript?(name) ?? false {
                        
                        return true
                        
                    }
                    
                    name = cls.rewriteScriptNameForKey?(name)  ?? name
                    
                }
                
            case let .Initializer(selector, _):
                
                if selector == #selector(_InitSelector.init(byScriptWithArguments:)) {
                    
                    member = .Initializer(selector: selector, arity: -1)
                    
                    name = ""
                    
                } else if let cls = plugin as? NKScriptExport.Type {
                    
                    name = cls.rewriteScriptNameForKey?(selector.description) ?? name
                    
                }
                
                if !name.isEmpty {
                    
                    return true
                    
                }
                
            }
            
            assert(members.indexForKey(name) == nil, "Plugin class \(plugin) has a conflict in member name '\(name)'")
            
            members[name] = member
            
            return true
            
        }
        
    }
    
    private func enumerateExcluding(excludeKnown: Set<Selector>, @noescape callback: ((String, Member)->Bool)) -> Bool {
        
        
        // enumerate protocols to match NKScriptExport
        var includeKnown: Set<Selector>? = nil
        
        var count: UInt32 = 0
        let protocols: AutoreleasingUnsafeMutablePointer<Protocol?> = class_copyProtocolList(plugin, &count)
        for i: UInt32 in 0 ..< count {
            let protoco = protocols[Int(i)]
            
            var count2: UInt32 = 0
            let protocols2: AutoreleasingUnsafeMutablePointer<Protocol?> = protocol_copyProtocolList(protoco, &count2)
            for j: UInt32 in 0 ..< count2 {
                let protoco2 = protocols2[Int(j)]
                
                if protocol_isEqual(protoco2, NKScriptExport.self)
                {
                    includeKnown = NKInstanceMethods(forProtocol: protoco!)
                    break
                }
            }
        }
        
        
        // enumerate methods
        let methodList = class_copyMethodList(plugin, nil)
        
        if methodList != nil, var method = Optional(methodList) {
            
            defer { free(methodList) }
            
            while method.memory != nil {
                
                let sel = method_getName(method.memory)
                
                if ((includeKnown != nil) && includeKnown!.contains(sel)) || ((includeKnown == nil) && !excludeKnown.contains(sel) && !sel.description.hasPrefix(".")) {
                    
                    let arity = Int32(method_getNumberOfArguments(method.memory) - 2)
                    
                    let member: Member
                    
                    if sel.description.hasPrefix("init") {
                        
                        member = Member.Initializer(selector: sel, arity: arity)
                        
                    } else {
                        
                        member = Member.Method(selector: sel, arity: arity)
                        
                    }
                    
                    var name = sel.description
                    
                    if let end = name.characters.indexOf(":") {
                        
                        name = name[name.startIndex ..< end]
                        
                    }
                    
                    if !callback(name, member) {
                        
                        return false
                        
                    }
                    
                }
                
                method = method.successor()
                
            }
            
        }
        
        return true
        
    }
    
}

extension NKScriptTypeInfo {
    
    // SequenceType
    
    typealias Generator = DictionaryGenerator<String, Member>
    
    func generate() -> Generator {
        
        return members.generate()
        
    }
    
    // CollectionType
    
    typealias Index = DictionaryIndex<String, Member>
    
    var startIndex: Index {
        
        return members.startIndex
        
    }
    
    var endIndex: Index {
        
        return members.endIndex
        
    }
    
    subscript (position: Index) -> (String, Member) {
        
        return members[position]
        
    }
    
    subscript (name: String) -> Member? {
        
        return members[name]
        
    }
    
}

public func NKInstanceMethods(forProtocol aProtocol: Protocol) -> Set<Selector> {
    
    var selectors = Set<Selector>()
    
    for (req, inst) in [(true, true), (false, true)] {
        
        let methodList = protocol_copyMethodDescriptionList(aProtocol.self, req, inst, nil)
        
        if methodList != nil, var desc = Optional(methodList) {
            
            while desc.memory.name != nil {
                
                selectors.insert(desc.memory.name)
                
                desc = desc.successor()
                
            }
            
            free(methodList)
            
        }
        
    }
    
    return selectors
}
