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

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}

/**
An OAuth1Session implementation the stores OAuth1 metadata in-memory
*/
public class MemoryOAuth1Session: OAuth1Session {
    
    /**
    The account id.
    */
    public var accountId: String
    
    public var token: String?
    
    public var tokenSecret: String?
    
    public var verifier: String?
    
    /**
    Save in memory tokens information.
    */
    public func save(token: String, tokenSecret: String) {
        self.token = token
        self.tokenSecret = tokenSecret
    }
    
    /**
    Clear all tokens. Method used when doing logout or revoke.
    */
    public func clearTokens() {
        self.token = nil
        self.tokenSecret = nil
        self.verifier = nil
    }
    
    /**
    Initialize session using account id.
    
    :param: accountId uniqueId to identify the OAuth1module
    :param: token optional parameter to initilaize the storage with initial values
    :param: tokenSecret optional parameter to initilaize the storage with initial values
    */
    public init(accountId: String, token: String? = nil, tokenSecret: String? = nil, verifier: String? = nil) {
        self.token = token
        self.tokenSecret = tokenSecret
        self.verifier = verifier
        self.accountId = accountId
    }
}
