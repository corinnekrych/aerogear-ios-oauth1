# aerogear-ios-oauth1 

> **NOTE:**  The library has been tested with Xcode 6.1.1

OAuth1 Client based on [aerogear-ios-http](https://github.com/aerogear/aerogear-ios-http). 

100% Swift.

|                 | Project Info  |
| --------------- | ------------- |
| License:        | Apache License, Version 2.0  |
| Build:          | Cocoapods  |
| Documentation:  | https://aerogear.org/docs/guides/aerogear-ios-2.X/ |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS  |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))  |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))  |


## Example Usage

### OAuth1 grant
```swift
    var http = Http(requestSerializer: HttpRequestSerializer()) // [1]
    
    let config = OAuth1Config(accountId: "Twitter",             // [2]
        base: "https://api.twitter.com/oauth/",
        requestTokenEndpoint: "request_token",
        authorizeEndpoint: "authorize",
        accessTokenEndpoint: "access_token",
        redirectURL: "YOUR_BUNDLE_ID://oauth-callback/twitter",
        clientId: "YOUR_CLIENT_ID",
        clientSecret: "YOUR_CLIENT_SECRET")
    
    let oauth1 = OAuth1Module(config: config)                   // [3]
    http.authzModule = oauth1                                   // [4]
    
    parameters["status"] = "Content of your tweet"              // [5]
    http.POST("https://api.twitter.com/1.1/statuses/update.json", parameters: parameters, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
        if let error = error {
            println("error: \(error)")
        }
        println("TWEETED")
    })
```
Create an instance of Http [1] from [aerogear-ios-http](https://github.com/aerogear/aerogear-ios-http) a thin layer on top of NSURLSession.

Fill-in the OAuth1 configuration in [2].

Create an OAuth1Module in [3] and inject OAuth1Module into http object in [4]. 

In [5] simply do your post, http layer will take care of triggering OAuth1 danse.

See full description in [aerogear.org](https://aerogear.org/docs/guides/aerogear-ios-2.X/Authorization/)

### Build, test and play with aerogear-ios-oauth1

1. Clone this project

2. Get the dependencies

The project uses [cocoapods](http://cocoapods.org) 0.36 release for handling its dependencies. As a pre-requisite, install [cocoapods](http://blog.cocoapods.org/CocoaPods-0.36/) and then install the pod. On the root directory of the project run:
```bash
pod install
```
3. open AeroGearOAuth1.xcworkspace

## Adding the library to your project 
To add the library in your project, you can either use [Cocoapods](http://cocoapods.org) or manual install in your project. See the respective sections below for instructions:

### Using [Cocoapods](http://cocoapods.org)
Support for Swift frameworks is supported from [CocoaPods-0.36 release](http://blog.cocoapods.org/CocoaPods-0.36/) upwards. In your ```Podfile``` add:

```
pod 'AeroGearOAuth1'
```

and then:

```bash
pod install
```

to install your dependencies

### Manual Installation
Follow these steps to add the library in your Swift project:

1. Add AeroGearOAuth1 as a [submodule](http://git-scm.com/docs/git-submodule) in your project. Open a terminal and navigate to your project directory. Then enter:
```bash
git submodule add https://github.com/aerogear/aerogear-ios-oauth1
.git
```
2. Open the `aerogear-ios-oauth1` folder, and drag the `AeroGearOAuth1.xcodeproj` into the file navigator in Xcode.
3. In Xcode select your application target  and under the "Targets" heading section, ensure that the 'iOS  Deployment Target'  matches the application target of AeroGearOAuth1.framework (Currently set to 8.0).
5. Select the  "Build Phases"  heading section,  expand the "Target Dependencies" group and add  `AeroGearOAuth1.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `AeroGearOAuth1.framework`.

## Documentation

For more details about the current release, please consult [our documentation](https://aerogear.org/docs/guides/aerogear-ios-2.X/).

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.