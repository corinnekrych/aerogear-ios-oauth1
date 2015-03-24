/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import CryptoSwift

public var timestampSince1970 = {String(Int64(NSDate().timeIntervalSince1970))}
public var nonceNSUUID = {(NSUUID().UUIDString as NSString).substringToIndex(8)}

public func authorizationHeaderForMethod(method: String, url: NSURL, parameters: [String: AnyObject], clientId: String, clientSecret: String, token: String? = nil, tokenSecret: String? = nil, timestamp: () -> String = timestampSince1970, nonce: () -> String = nonceNSUUID) -> String {
    var authzParam = [String: AnyObject]()
    authzParam["oauth_version"] = "1.0"
    authzParam["oauth_signature_method"] = "HMAC-SHA1"
    authzParam["oauth_consumer_key"] = clientId
    authzParam["oauth_timestamp"] = timestamp()
    authzParam["oauth_nonce"] = nonce()
    
    if token != nil {
        authzParam["oauth_token"] = token
    }
    
    // Overriding authz params with authz param from method call
    for (key, value: AnyObject) in parameters {
        if key.hasPrefix("oauth_") {
            authzParam.updateValue(value, forKey: key)
        }
    }
    
    // All parameters
    var combinedParameters = authzParam
    for (key, value: AnyObject) in parameters {
        combinedParameters.updateValue(value, forKey: key)
    }
    
    // Add signature. Signature take in account all parameter
    if let signature = signatureForMethod(method, url, combinedParameters, clientId, clientSecret, token, tokenSecret) {
        authzParam["oauth_signature"] = signature
    }
    
    // Oauth1 parameters must be sorted alphabetically
    var parameterComponents = urlEncode(authzParam)
    parameterComponents.sort { $0 < $1 }
    
    // Format OAuth header
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
    // Signing key always includes & even with empty token secret
    let signingKey = "\(encodedConsumerSecret)&\(tokenSecretEncoded)"
    var parameterComponents = urlEncode(parameters)
    parameterComponents.sort { $0 < $1 }
    
    // Sort parameterss
    let parameterString = "&".join(parameterComponents).urlEncode()
    
    let encodedURL = url.absoluteString!.urlEncode()
    
    let signatureBaseString = "\(method)&\(encodedURL)&\(parameterString)"
    // Hash using HMAC-SHA1
    let key = signingKey.dataUsingEncoding(NSUTF8StringEncoding)!
    let msg = signatureBaseString.dataUsingEncoding(NSUTF8StringEncoding)!
    
    let sha1 = Authenticator.HMAC(key: key, variant: .sha1).authenticate(msg)
    if sha1 == nil {
        return nil
    }
    return sha1!.base64EncodedStringWithOptions(nil)
    
}
