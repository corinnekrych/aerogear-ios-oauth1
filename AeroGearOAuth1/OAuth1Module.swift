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
    public required init(config: OAuth1Config, session: OAuth1Session? = nil, requestSerializer: RequestSerializer = HttpRequestSerializer(), responseSerializer: ResponseSerializer = JsonResponseSerializer()) {

        if (session == nil) {
            self.oauth1Session = UntrustedMemoryOAuth1Session(accountId: config.accountId!)
        } else {
            self.oauth1Session = session!
        }

        self.config = config

        self.http = Http(baseURL: config.baseURL, requestSerializer: requestSerializer, responseSerializer:  responseSerializer)
        self.state = .AuthorizationStateUnknown
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

    // MARK: Public API - To be overriden if necessary by OAuth1 specific adapter
    
    /* 
    Step1. First init request asking for temporary token and token secret
    http://tools.ietf.org/html/rfc5849#section-2.1
    */
    public func requestToken(completionHandler: (AnyObject?, NSError?) -> Void) {
        var parameters =  [String: AnyObject]()
        parameters["oauth_callback"] = config.redirectURL
        
        // Build Json request with OAuth1 header
        let request = JsonRequestSerializer()
        let url = self.calculateURL(config.baseURL, url: config.requestTokenEndpoint)
        let headers = ["Authorization":  authorizationHeaderForMethod("POST", url, parameters, config.clientId, config.clientSecret, token: nil, tokenSecret: nil)]
        // Make POST http call to ask temporary token
        self.http.POST(config.requestTokenEndpoint, parameters: parameters, headers: headers, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
            //
            println("RESPONSE::\(response)")
            //let responseString = NSString(data: response, encoding: NSUTF8StringEncoding) as String
//            let parameters = self.parametersFromQueryString(responseString)
//            self.oauth1Session.oauth_token = parameters["oauth_token"]!
//            self.oauth1Session.oauth_token_secret = parameters["oauth_token_secret"]!
        })
        

        
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

        // calculate final url
        var params = "?&redirect_uri=\(config.redirectURL.urlEncode())&client_id=\(config.clientId)&response_type=code"
        UIApplication.sharedApplication().openURL(NSURL(string: http.calculateURL(config.baseURL, url:config.authorizeEndpoint).absoluteString! + params)!)
    }
    
    /**
    Gateway to request authorization access

    :param: completionHandler A block object to be executed when the request operation finishes.
    */
    public func requestAccess(completionHandler: (AnyObject?, NSError?) -> Void) {
        if (self.oauth1Session.token != nil) {
            // we already have a valid access token, nothing more to be done
            completionHandler(self.oauth1Session.token!, nil);
        } else {
            // ask for authorization code and once obtained exchange code for access token
            self.requestToken(completionHandler)
        }
    }
    
  /**
    Return any authorization fields

    :returns:  a dictionary filled with the authorization fields
    */
    public func authorizationFields() -> [String: String]? {
        if (self.oauth1Session.token == nil) {
            return nil
        } else {
            return ["Authorization":"Bearer \(self.oauth1Session.token!)"]
        }
    }


    // MARK: Internal Methods

    func extractCode(notification: NSNotification, completionHandler: (AnyObject?, NSError?) -> Void) {
//        let url: NSURL? = (notification.userInfo as [String: AnyObject])[UIApplicationLaunchOptionsURLKey] as? NSURL
//
//        // extract the code from the URL
//        let code = self.parametersFromQueryString(url?.query)["code"]
//        // if exists perform the exchange
//        if (code != nil) {
//            self.exchangeAuthorizationCodeForAccessToken(code!, completionHandler: completionHandler)
//            // update state
//            state = .AuthorizationStateApproved
//        } else {
//
//            let error = NSError(domain:AGAuthzErrorDomain, code:0, userInfo:["NSLocalizedDescriptionKey": "User cancelled authorization."])
//            completionHandler(nil, error)
//        }
//        // finally, unregister
//        self.stopObserving()
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
