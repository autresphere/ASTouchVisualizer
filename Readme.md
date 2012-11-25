## ASTouchVisualizer
ASTouchVisualizer is a simple class that shows multitouch events on top of all your views.

It is used to create iPhone or iPad video tutorials on which finger movement is clearly seen.

It is dead simple to use in a project, no overloading needed. Just copy the file in your project and call the install method.

![](https://github.com/autresphere/ASTouchVisualizer/raw/master/Screenshots/iPhone.png)
![](https://github.com/autresphere/ASTouchVisualizer/raw/master/Screenshots/iPhoneVideo.gif)

## Try it
Download the whole project and run it under Xcode. You can choose either iPhone or iPad destination.
It supports all orientations change.

## Use it
Just copy ASTouchVisualizer.h and ASTouchVisualizer.m in your project.

In your App delegate, add
``` objective-c
#import "ASTouchVisualizer.h"
```

then just after
``` objective-c
[self.window makeKeyAndVisible];
```

call
``` objective-c
[ASTouchVisualizer install];
```
### ARC Support
This class requires ARC.
