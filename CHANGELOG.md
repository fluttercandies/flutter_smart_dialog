# [4.3.x]

- Adapt to flutter 3
- Add SmartAwaitOverType
- Fix [#56](https://github.com/fluttercandies/flutter_smart_dialog/issues/56)
- Fix [#60](https://github.com/fluttercandies/flutter_smart_dialog/issues/60)

# [4.0.3]

- Fix [#53](https://github.com/fluttercandies/flutter_smart_dialog/issues/53)
- Fix back event cannot close loading
- Add SmartAwaitOverType
- Fix [#56](https://github.com/fluttercandies/flutter_smart_dialog/issues/56)
- Fix [#60](https://github.com/fluttercandies/flutter_smart_dialog/issues/60)

# [4.0.0]

- Breaking Change!!! migrate doc: [3.x migrate 4.0](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/3.x%20migrate%204.0.md) | [3.x 迁移 4.0](https://juejin.cn/post/7093867453012246565)
- Major update
- Subdivided 'config', can control 'show', 'showAttach', 'showLoading', 'showToast' in more detail
- Add 'bindPage' feature, it can reasonably solve the problem of dialog jumping pages
- Now 'dismiss' can carry the return value, similar to pop and push usage
- You can use the 'permanent' param to set a permanent dialog
- The interval time that can be added between successive displays of toasts
- Loading can set the least loading time
- Add click listener for dialog mask


# [3.4.x]

- 'showToast' add 'consumeEvent' param: [#27](https://github.com/fluttercandies/flutter_smart_dialog/issues/27)
- 'dismiss' can close dialogs with duplicate tags
- Fix [#28](https://github.com/fluttercandies/flutter_smart_dialog/issues/28)
- Fix [#42](https://github.com/fluttercandies/flutter_smart_dialog/issues/42)
- Fix [#34](https://github.com/fluttercandies/flutter_smart_dialog/issues/41) [#41](https://github.com/fluttercandies/flutter_smart_dialog/issues/34)
- Add SmartStatus.allToast

# [3.3.x]

- Notice: 'antiShake' renamed 'debounce'
- Add use System dialog feature
- Solve the page jump scene on the dialog (useSystem)
- SmartStatus add status：custom，attach，allCustom
- The entry 'init' method can customize the default style of Toast and Loading
- Optimize toast：The toast no longer consumes touch events
- Add SmartStatus.smart
- Fixed the problem that the top-of-stack dialog would be closed if the tags did not match

# [3.2.x]

- Major update！
- Add 'showAttach' feature
- Support positioning widget, display the specified location dialog
- Support highlight feature，dissolve the specified location mask
- Optimize 'keepSingle' feature

# [3.1.x]

- 'show' method add 'keepSingle' function
- Optimize dismiss method

# [3.0.x]

- Support dialog stack，close the specified dialog
- support open multi dialog
- Monitor back and pop event, then close dialog reasonably
- Initialization is more concise
- Add debounce feature
- Add close all dialog status
- Adjustment comment
- Add four toast display logic
- Compatible with cupertino style
- Increase showToast's external exposure param

# [2.3.x]

- optimize function
- solve problem of keyboard shelter toast
- optimize toast. remove isDefaultDismissType api

# [2.1.x]

- reconstruction of the underlying logic
- adjust toast default duration
- add maskWidget param

# [2.0.x]

- migrate null-safety
- adapt flutter 2.0

# [1.3.x]

- Improve toast display
- Improve toast customization function

# [1.2.x]

- loadingDialog perfect parameter settings
- adjust and use show method
- add dismiss callback

# [1.1.x]

- simplified use
- fix bug, adjust the default value of clickBgDismiss attribute to true

# [1.0.3] [1.0.5]

- improve the usage details in the document

# [1.0.1]

- perfect some function

# [0.1.7]

- perfect description

# [0.1.6]

- short descriptio

# [0.1.5]

- perfect description

# [0.1.3]

- adjust code of example

# [0.1.2]

- add example

# [0.1.1]

- remove some constructors

# [0.1.0]

- property debugging is complete

# [0.0.4]

- dealing with the problem of package name

# [0.0.1]

- init