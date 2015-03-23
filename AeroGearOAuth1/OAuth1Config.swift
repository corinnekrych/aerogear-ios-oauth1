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

/**
Configuration object to setup an OAuth1a module
*/
public class OAuth1Config {
    /**
    Applies the baseURL to the configuration.
    */
    public let baseURL: String
    
    /**
    Applies the "callback URL" once request token issued.
    */
    public let redirectURL: String

    /**
    Applies the "initial request token endpoint" to the request token.
    */
    public var requestTokenEndpoint: String
    
    /**
    Applies the "authorization endpoint" to the request token.
    */
    public var authorizeEndpoint: String
    
    /**
    Applies the "access token endpoint" to the exchange code for access token.
    */
    public var accessTokenEndpoint: String
  
    /**
    Applies the "client id" obtained with the client registration process.
    */
    public let clientId: String
    
    /**
    Applies the "client secret" obtained with the client registration process.
    */
    public let clientSecret: String
    
    public let accountId: String?
    
    public init(accountId:String, base: String,
        requestTokenEndpoint: String,
        authorizeEndpoint: String,
        accessTokenEndpoint: String,
        redirectURL: String,
        clientId: String,
        clientSecret: String) {
            self.accountId = accountId
        self.baseURL = base
        self.requestTokenEndpoint = requestTokenEndpoint
        self.authorizeEndpoint = authorizeEndpoint
        self.redirectURL = redirectURL
        self.accessTokenEndpoint = accessTokenEndpoint
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}