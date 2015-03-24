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

import Foundation
import UIKit
import AeroGearHttp
import CryptoSwift

/**
Notification constants emitted during oauth authorization flow
*/
public let AGAppLaunchedWithURLNotification = "AGAppLaunchedWithURLNotification"
public let AGAppDidBecomeActiveNotification = "AGAppDidBecomeActiveNotification"
public let AGAuthzErrorDomain = "AGAuthzErrorDomain"

/**
The current state that this module is in

- AuthorizationStatePendingExternalApproval:  the module is waiting external approval
- AuthorizationStateApproved:                the oauth flow has been approved
- AuthorizationStateUnknown:                the oauth flow is in unknown state (e.g. user clicked cancel)
*/
enum AuthorizationState {
    case AuthorizationStatePendingExternalApproval
    case AuthorizationStateApproved
    case AuthorizationStateUnknown
}

/**
Parent class of any OAuth1 module implementing generic OAuth1a authorization flow.
Refer to specification: http://tools.ietf.org/html/rfc5849 for more details.
*/
public class OAuth1Module: AuthzModule {
    let config: OAuth1Config
    var http: Http
    
    var oauth1Session: OAuth1Session
    var applicationLaunchNotificationObserver: NSObjectProtocol?
    var applicationDidBecomeActiveNotificationObserver: NSObjectProtocol?
    var state: AuthorizationState
    
    /**
    Initialize an OAuth1 module
    
    :param: config                   the configuration object that setups the module
    :param: session                 the session that that module will be bound to
    :param: requestSerializer   the actual request serializer to use when performing requests
    :param: responseSerializer the actual response serializer to use upon receiving a response
    
    :returns: the newly initialized OAuth1Module
    */
    public required init(config: OAuth1Config, session: OAuth1Session? = nil, requestSerializer: RequestSerializer = HttpRequestSerializer(), responseSerializer: ResponseSerializer = StringResponseSerializer()) {
        
        if (session == nil) {
            self.oauth1Session = UntrustedMemoryOAuth1Session(accountId: config.accountId!)
        } else {
            self.oauth1Session = session!
        }
        
        self.config = config
        // use ephemeral to have http internal call without cookies
        self.http = Http(baseURL: config.baseURL, sessionConfig: NSURLSessionConfiguration.ephemeralSessionConfiguration(), requestSerializer: requestSerializer, responseSerializer:  responseSerializer)
        
        self.state = .AuthorizationStateUnknown
    }
    
    // MARK: Public API - To be overriden if necessary by OAuth1 specific adapter
    
    /*
    Step1. First init request asking for temporary token and token secret
    http://tools.ietf.org/html/rfc5849#section-2.1
    */
    public func requestToken(completionHandler: (AnyObject?, NSError?) -> Void) {
        var parameters =  [String: AnyObject]()
        parameters["oauth_callback"] = config.redirectURL
        
        // Build OAuth1 header
        let url = self.calculateURL(config.baseURL, url: config.requestTokenEndpoint)
        let headers = ["Authorization":  authorizationHeaderForMethod("POST", url, parameters, config.clientId, config.clientSecret, token: nil, tokenSecret: nil)]
        // Make POST http call to ask temporary token
        self.http.POST(config.requestTokenEndpoint, parameters: parameters, headers: headers, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
            // Chain with Step2
            if let response = response as? String {
                let parameters = self.parametersFromQueryString(response)
                self.oauth1Session.token = parameters["oauth_token"]
                self.oauth1Session.tokenSecret = parameters["oauth_token_secret"]
                self.authorize(completionHandler)
            }
        })
    }
    
    /*
    Step2. Ask for resource owner authorization using temporary token and token secret to sign
    http://tools.ietf.org/html/rfc5849#section-2.2
    */
    public func authorize(completionHandler: (AnyObject?, NSError?) -> Void) {
        // Chain with Step3
        applicationLaunchNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(AGAppLaunchedWithURLNotification, object: nil, queue: nil, usingBlock: { (notification: NSNotification!) -> Void in
            self.extractCode(notification, completionHandler: completionHandler)
        })
        
        applicationDidBecomeActiveNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(AGAppDidBecomeActiveNotification, object:nil, queue:nil, usingBlock: { (note: NSNotification!) -> Void in
            // check the state
            if (self.state == .AuthorizationStatePendingExternalApproval) {
                // unregister
                self.stopObserving()
                // ..and update state
                self.state = .AuthorizationStateUnknown;
            }
        })
        
        // update state to 'Pending'
        self.state = .AuthorizationStatePendingExternalApproval
        
        // Calculate final url to do http call for Step2
        if let token = self.oauth1Session.token {
            if let url = NSURL(string: http.calculateURL(config.baseURL, url:config.authorizeEndpoint).absoluteString! + "?oauth_token=\(token)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    /*
    Step3. Ask for inal tokens.
    http://tools.ietf.org/html/rfc5849#section-2.3
    */
    public func exchangeForAccessToken(completionHandler: (AnyObject?, NSError?) -> Void) {
        var parameters =  [String: AnyObject]()
        if let token = self.oauth1Session.token {
            if let verifier = self.oauth1Session.verifier {
                parameters["oauth_token"] = token
                parameters["oauth_verifier"] = self.oauth1Session.verifier
                
                // Build OAuth1 header
                let url = self.calculateURL(config.baseURL, url: config.accessTokenEndpoint)
                let headers = ["Authorization":  authorizationHeaderForMethod("POST", url, parameters, config.clientId, config.clientSecret, token: self.oauth1Session.token, tokenSecret:  self.oauth1Session.tokenSecret)]
                
                //var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                
                self.http.POST(config.accessTokenEndpoint, parameters: [:], headers: headers, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                    if let response = response as? String {
                        let parameters = self.parametersFromQueryString(response)
                        self.oauth1Session.token = parameters["oauth_token"]
                        self.oauth1Session.tokenSecret = parameters["oauth_token_secret"]
                        completionHandler(parameters, nil)
                    }
                })
            }
        } else {}
    }
    
    /**
    Gateway to request authorization access
    
    :param: completionHandler A block object to be executed when the request operation finishes.
    */
    // TODO
    public func requestAccess(completionHandler: (AnyObject?, NSError?) -> Void) {
        self.requestToken(completionHandler)
    }
    
    /**
    Return any authorization fields
    
    :returns:  a dictionary filled with the authorization fields
    */
    public func authorizationFields(endpoint: String?, parameters: [String: AnyObject]?) -> [String: String]? {
        let url = self.calculateURL(config.baseURL, url: endpoint!)
        let headers = ["Authorization":  authorizationHeaderForMethod("POST", url, parameters!, config.clientId, config.clientSecret, token: self.oauth1Session.token, tokenSecret: self.oauth1Session.tokenSecret)]
        
        if (self.oauth1Session.token == nil) {
            return nil
        } else {
            return headers
        }
    }
    
    
    // MARK: Internal Methods
    
    func extractCode(notification: NSNotification, completionHandler: (AnyObject?, NSError?) -> Void) {
        let url: NSURL? = (notification.userInfo as [String: AnyObject])[UIApplicationLaunchOptionsURLKey] as? NSURL
        
        // extract the code from the URL
        let extractedParams = self.parametersFromQueryString(url?.query)
        if let oauthToken = extractedParams["oauth_token"] {
            if let oauthVerifier = extractedParams["oauth_verifier"] {
                self.oauth1Session.token = oauthToken
                self.oauth1Session.verifier = oauthVerifier
                // Chain with Setp 3
                self.exchangeForAccessToken(completionHandler)
                // update state
                state = .AuthorizationStateApproved
            }
        } else {
            // Failure in OAuth1 flow
            let error = NSError(domain: AGAuthzErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failure in OAuth1 flow"])
            completionHandler(nil, error);
        }
        
        // finally, unregister
        self.stopObserving()
    }
    
    func parametersFromQueryString(queryString: String?) -> [String: String] {
        var parameters = [String: String]()
        if (queryString != nil) {
            var parameterScanner: NSScanner = NSScanner(string: queryString!)
            var name:NSString? = nil
            var value:NSString? = nil
            
            while (parameterScanner.atEnd != true) {
                name = nil;
                parameterScanner.scanUpToString("=", intoString: &name)
                parameterScanner.scanString("=", intoString:nil)
                
                value = nil
                parameterScanner.scanUpToString("&", intoString:&value)
                parameterScanner.scanString("&", intoString:nil)
                
                if (name != nil && value != nil) {
                    parameters[name!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!] = value!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                }
            }
        }
        
        return parameters;
    }
    
    func calculateURL(baseURL: String?,  var url: String) -> NSURL {
        if (baseURL == nil || url.hasPrefix("http")) {
            return NSURL(string: url)!
        }
        
        var finalURL = NSURL(string: baseURL!)!
        if (url.hasPrefix("/")) {
            url = url.substringFromIndex(advance(url.startIndex, 0))
        }
        
        return finalURL.URLByAppendingPathComponent(url);
    }
    
    deinit {
        self.stopObserving()
    }
    
    func stopObserving() {
        // clear all observers
        if (applicationLaunchNotificationObserver != nil) {
            NSNotificationCenter.defaultCenter().removeObserver(applicationLaunchNotificationObserver!)
            self.applicationLaunchNotificationObserver = nil;
        }
        
        if (applicationDidBecomeActiveNotificationObserver != nil) {
            NSNotificationCenter.defaultCenter().removeObserver(applicationDidBecomeActiveNotificationObserver!)
            applicationDidBecomeActiveNotificationObserver = nil
        }
    }
    
}
