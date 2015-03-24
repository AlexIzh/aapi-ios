//
//  NSURL+aapi.swift
//  AAPILibrary_swift
//
//  Created by Alex on 3/23/15.
//  Copyright (c) 2015 moqod. All rights reserved.
//

import Foundation
import UIKit

let NSURLAlterAPIKey					= "NSURLAlterAPIKey";

extension NSURL {
    struct aaStatic {
        static var projectId:String? = nil
        static var requestURL:String? = "aapi.io/request"
        static var excludedURLSet:[String]? = nil
        static var includedURLSet:[String]? = nil
    }
    class var aaProjectId:String?{
        get { return aaStatic.projectId }
        set {aaStatic.projectId = newValue?.copy() as? String}
    }
    class var aaRequestURL:String?{
        get{ return aaStatic.requestURL }
        set{ aaStatic.requestURL = newValue?.copy() as? String }
    }
    class var aaExcludedURLSet:[String]?{
        get{ return aaStatic.excludedURLSet }
        set{ aaStatic.excludedURLSet = aaExcludedURLSet }
    }
    class var aaIncludedURLSet:[String]?{
        get{ return aaStatic.includedURLSet }
        set{ aaStatic.includedURLSet = aaIncludedURLSet }
    }
    func aaIsInjected()->Bool? {
        return objc_getAssociatedObject(self, NSURLAlterAPIKey) as? Bool
    }
    
    private func aaMarkAsInjected() {
        objc_setAssociatedObject(self, NSURLAlterAPIKey, true, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    class func aaIsURLExcluded(url:String!)->Bool! {
        if ((aaStatic.excludedURLSet?.count) != nil) {
            var isExistInList = false
            if let set:[String]! = aaStatic.includedURLSet {
                for excludedHost in set {
                    if (url.hasPrefix(excludedHost as String) != false) {
                        isExistInList = true;
                        break;
                    }
                }
            }
            if (!isExistInList) {
                return true
            }
        }
        if let set = aaStatic.excludedURLSet {
            for excludedHost in set {
                if (url.hasPrefix(excludedHost as String) != false) {
                    return true
                }
            }
        }
        return false
    }
    
    class func aaQueryParamsStringFor(url:String)->String {
        var dict:[String:String] = Dictionary()
        dict["pid"] = aaStatic.projectId
        dict["dname"] = UIDevice.currentDevice().name
        dict["model"] = UIDevice.currentDevice().model
        dict["os"] = UIDevice.currentDevice().systemName
        dict["osv"] = UIDevice.currentDevice().systemVersion
        dict["did"] = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        var queryString:String = ""
        for key in dict.keys {
            let string = dict[key]?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            queryString += "/\(key)/\(string!)"
        }
        queryString += "/url/\(url)"
        return queryString
    }
    
    class func aaURLStringByInjectingAlterAPI(urlString URLString:String)->(String, Bool) {
        let hasHTTPScheme = URLString.hasPrefix("http")
        let hasHTTPSScheme = URLString.hasPrefix("https")
        var injected = false
        var urlString = URLString
        if (aaStatic.projectId != nil && (hasHTTPScheme || hasHTTPSScheme) && (URLString.rangeOfString(aaStatic.requestURL!) == nil ) ) {
            if self.aaIsURLExcluded(URLString) != nil {
                let scheme = (hasHTTPScheme ? "http":"https")
                let _string = aaStatic.requestURL!
                let params = self.aaQueryParamsStringFor(URLString)
                urlString = "\(scheme)://\(_string)\(params)"
                injected = true
            }
        }
        return (urlString, injected)
    }
    
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== NSURL.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = Selector("initWithString:relativeToURL:")
            let swizzledSelector = Selector("aa_initWithString:relativeToURL:")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
    func aa_init(string URLString: String, relativeToURL baseURL: NSURL?)->NSURL {
        var injected = false
        var urlString:String
        (urlString, injected) = NSURL.aaURLStringByInjectingAlterAPI(urlString: URLString)
        let url:NSURL = self.aa_init(string: urlString, relativeToURL: baseURL)
        if (injected) {
            url.aaMarkAsInjected()
        }
        return url;
    }
}