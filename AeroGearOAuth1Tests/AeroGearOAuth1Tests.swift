//
//  AeroGearOAuth1Tests.swift
//  AeroGearOAuth1Tests
//
//  Created by Corinne Krych on 23/03/15.
//  Copyright (c) 2015 aerogear. All rights reserved.
//

import UIKit
import XCTest
import AeroGearOAuth1
public var timestamp = {"1427128157"}
public var nonce = {"B78A4575"}
class AeroGearOAuth1Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testSignature() {
//        let url = NSURL(string: "http://example.com/request")
//        let parameters = ["b5": "=%3D",
//                   "a3": "a",
//                   "c@": "",
//                   "a2": "r b",
//                   "oauth_consumer_key": "9djdj82h48djs9d2",
//                   "oauth_token": "kkk9d7dh3k39sjv7",
//                   "oauth_signature_method": "HMAC-SHA1",
//                   "oauth_timestamp": "137131201",
//                   //"oauth_nonce ": "7d8f3e4a",
//                   "c2": ""]
//        var signature = authorizationHeaderForMethod("POST", url!, parameters, "clienId", "clienSecret", token:nil, tokenSecret: nil)
//        println(":::\(signature)")
//    }
    
    func testSignatureTwitter() {

        let url = NSURL(string: "https://api.twitter.com/oauth/request_token")
        let parameters = ["oauth_callback": "oauth-swift://oauth-callback/twitter"]
        var signature = authorizationHeaderForMethod("POST", url!, parameters, "aTaSn8tBgQhSKSLotaPWnC0w7", "fvyCKCECrDXUqBtDGmgbxuXt2fhlsq2Feb18pSvpoF3zWIpoAP", token:nil, tokenSecret: nil)
        println(":::TWITTER::\(signature)")
    }
    

}
