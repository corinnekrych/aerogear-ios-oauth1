//
//  OAuth1Signature.swift
//  AeroGearOAuth1
//
//  Created by Corinne Krych on 23/03/15.
//  Copyright (c) 2015 aerogear. All rights reserved.
//

import CryptoSwift

public var timestamp = {String(Int64(NSDate().timeIntervalSince1970))}
public var nonce = {(NSUUID().UUIDString as NSString).substringToIndex(8)}

public func authorizationHeaderForMethod(method: String, url: NSURL, parameters: [String: AnyObject], clientId: String, clientSecret: String, token: String? = nil, tokenSecret: String? = nil) -> String {
    var authzParam = [String: AnyObject]()
    authzParam["oauth_version"] = "1.0"
    authzParam["oauth_signature_method"] = "HMAC-SHA1"
    authzParam["oauth_consumer_key"] = clientId
    authzParam["oauth_timestamp"] = timestamp()
    authzParam["oauth_nonce"] = nonce()
    
    if (token != nil){
        authzParam["oauth_token"] = token
    }
    
    // Add others params, overriding authz params if needed
    for (key, value: AnyObject) in parameters {
        authzParam.updateValue(value, forKey: key)
    }
    
    // Add signature
    println("finalParameters::\(authzParam)")
    if let signature = signatureForMethod(method, url, authzParam, clientId, clientSecret, token, tokenSecret) {
        authzParam["oauth_signature"] = signature
    }
    
    // Parameters must be sorted alphabetically
    var parameterComponents = urlEncode(authzParam)
    parameterComponents.sort { $0 < $1 }
    
    var headerComponents = [String]()
    for component in parameterComponents {
        let subcomponent = component.componentsSeparatedByString("=") as [String]
        if subcomponent.count == 2 {
            headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
        }
    }
    
    return "OAuth " + ", ".join(headerComponents)
}

// Mark - Internal utilities functions
func urlEncode(dict: [String: AnyObject]) -> [String] {
    var parts = [String]()
    
    for (key, value) in dict {
        let keyString = key.urlEncode()
        let valueString = (value as String).urlEncode()
        let query = "\(keyString)=\(valueString)"
        parts.append(query)
    }
    
    return parts
}

func signatureForMethod(method: String, url: NSURL, parameters: [String: AnyObject], clientId: String, clientSecret: String, token: String?, tokenSecret: String?) -> String? {
    var tokenSecretEncoded = ""
    if let tokenSecret = tokenSecret {
        tokenSecretEncoded = tokenSecret.urlEncode()
    }
    let encodedConsumerSecret = clientSecret.urlEncode()
    
    let signingKey = "\(encodedConsumerSecret)&\(tokenSecretEncoded)"
    println("signingKey::\(signingKey)")
    var parameterComponents = urlEncode(parameters)
    parameterComponents.sort { $0 < $1 }
    
    let parameterString = "&".join(parameterComponents).urlEncode()
    
    let encodedURL = url.absoluteString!.urlEncode()
    
    let signatureBaseString = "\(method)&\(encodedURL)&\(parameterString)"
    println("signatureBaseString::\(signatureBaseString)")
    let key = signingKey.dataUsingEncoding(NSUTF8StringEncoding)!
    let msg = signatureBaseString.dataUsingEncoding(NSUTF8StringEncoding)!
    println("key=\(key):::msg=\(msg)")
    let sha1 = Authenticator.HMAC(key: key, variant: .sha1).authenticate(msg)
    if sha1 == nil {
        return nil
    }
    let str = sha1!.base64EncodedStringWithOptions(nil)
    println("sha1::\(str)")
    return str
}
