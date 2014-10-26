DTIToastCenter-Swift
====================

A toast center for displaying quick toast to the user written in full swift.
Toasts are displayed with great animation.
Toasts are bounded to keyWindow, handle screen rotation and resize/move when keyboard is shown/hidden.
Center is inspired from Takpku library
Center can be called from both swift or objc project.
Some functionnalities have been inspired from TKAlertCenter (tapku library)
DTIToastCenter-Swift required IOS7 & more.

Warning !
Simulator dont handle correctly view rotations when binded to keyWindow, so to test this functionnality you need to use a physical device.

<img src="Shots/toastcenter.gif"/> &nbsp; 

### Installation
Support for swift project is not yet supported by cocoapod.
I will create a podspec file later.
DTIActivityIndicatorView will be available through [CocoaPods](http://cocoapods.org).
For instance, you will have to manually copy Classes/* in your project.

You can see work progress here:
https://github.com/CocoaPods/CocoaPods/issues/2272

This component require **Xcode6.1** to compile.

### Usage

Initialize center in your application delegate to listen keyboard events

*objc*
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[DTIToastCenter defaultCenter] registerCenter];
    return YES;
}
```

Post alert with text
```objc
[[DTIToastCenter defaultCenter] makeText:@"Hey! This is the toast system."];
```

Post alert with image
```objc
[[DTIToastCenter defaultCenter] makeImage:[UIImage imageNamed:@"swift"]];
```

Post alert with image and text
```objc
[[DTIToastCenter defaultCenter] makeText:@"Toast with image !" image:[UIImage imageNamed:@"swift"]];
```
