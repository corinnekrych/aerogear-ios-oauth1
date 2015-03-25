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


import UIKit
import XCTest
import AeroGearOAuth1

class AeroGearOAuth1Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCheckingTwitterSignatureWithFixedNonceAndTimestamp() {
        let url = NSURL(string: "https://api.twitter.com/oauth/request_token")
        var parameters = ["oauth_callback": "oauth-swift://oauth-callback/twitter"]
        parameters["oauth_nonce"] = "B78A4575"
        parameters["oauth_timestamp"] = "1427128157"
        var signature = authorizationHeaderForMethod("POST", url!, parameters, "aTaSn8tBgQhSKSLotaPWnC0w7", "fvyCKCECrDXUqBtDGmgbxuXt2fhlsq2Feb18pSvpoF3zWIpoAP", token:nil, tokenSecret: nil)
        XCTAssertTrue((signature as NSString).containsString("oauth_signature=\"AdwwWXXKx3%2BE%2Bag%2FqRmm7Z63oqY%3D\""), "Fixing nonce and timestamp signature should be valid")
    }
    

}
