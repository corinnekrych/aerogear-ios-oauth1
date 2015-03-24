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
The protocol that an OAuth1 Session modules must adhere to and represent storage of oauth specific metadata. See TrustedPersistantOAuth1Session and UntrustedMemoryOAuth1Session as example implementations
*/
public protocol OAuth1Session {
    
    /**
    The account id.
    */
    var accountId: String {get}
    
    /**
    The temporary token.
    */
    var token: String? {get set}
    
    /**
    The temporary secret token.
    */
    var tokenSecret: String? {get set}
    
    /**
    The verifier genrated in step 2 of OAuth1.
    */
    var verifier: String? {get set}
    
    /**
    Clears any tokens storage
    */
    func clearTokens()
    
    /**
    Save tokens information. Saving tokens allow you to refresh accesstoken transparently for the user without prompting
    for grant access.
    
    :param: accessToken the access token
    :param: refreshToken  the refresh token
    :param: accessTokenExpiration the expiration for the access token
    :param: refreshTokenExpiration the expiration for the refresh token
    */
    func save(token: String, tokenSecret: String)
}
