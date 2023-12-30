# [4.9.x]
* fix [#132](https://github.com/fluttercandies/flutter_smart_dialog/issues/132)
* optimize nonAnimationTypes
* toast add some param
* fix [#135](https://github.com/fluttercandies/flutter_smart_dialog/issues/135)
* optimize loading [#137](https://github.com/fluttercandies/flutter_smart_dialog/issues/137)
* optimize 'show debug point'
* fix [#142](https://github.com/fluttercandies/flutter_smart_dialog/issues/142)
* add checkExist
* fix [#162](https://github.com/fluttercandies/flutter_smart_dialog/issues/162)
* break change: "AlignmentGeometry" adjust to "Alignment"


# [4.9.0]
* Breaking Change
  * refactor Toast: remove 'SmartToastType.first' and 'SmartToastType.firstAndLast'
* Feature
  * add 'SmartToastType.multi': Can display multi toasts at the same time
  * add showNotify: By setting NotifyType, many different types of Notify dialog can be used
  * showNotify custom style: You can set the default dialog style for showNotify through the notifyStyle parameter in FlutterSmartDialog.init ()
  * solve [#102](https://github.com/fluttercandies/flutter_smart_dialog/issues/102)
  * solve [#111](https://github.com/fluttercandies/flutter_smart_dialog/issues/111)
* Stability
  * fix [#110](https://github.com/fluttercandies/flutter_smart_dialog/issues/110)
  * fix [#118](https://github.com/fluttercandies/flutter_smart_dialog/issues/118)
  * fix [#122](https://github.com/fluttercandies/flutter_smart_dialog/issues/122)
  * fix [#126](https://github.com/fluttercandies/flutter_smart_dialog/issues/126)  
  * fix [#128](https://github.com/fluttercandies/flutter_smart_dialog/issues/128)
  * optimize route monitor


# [4.8.x]
* Breaking Change
  * If the 'bindPage' of the dialog is false, the dialog will not be closed when the page is closed
* Optimize 'tag'
* Fix [#101](https://github.com/fluttercandies/flutter_smart_dialog/issues/101)
* Optimize 'bindWidget'
* Fix [#105](https://github.com/fluttercandies/flutter_smart_dialog/issues/105)


# [4.7.x]

* Breaking Change
  * Toast global default config adjustment(alignment: Alignment.center ---> Alignment.bottomCenter)
* Toast 'displayType' add 'onlyRefresh'
* Compatible with flutter_boost
* Add 'SmartAttachAlignmentType'
* Add 'SmartInitType'
* Optimize 'keepSingle', 'displayTime', 'tag'


# [4.6.x]

* Add 'bindWidget' feature
* Add 'nonAnimationTypes' feature
* Add 'ignoreArea' feature
* Fix [#81](https://github.com/fluttercandies/flutter_smart_dialog/issues/81)
* Fix [#82](https://github.com/fluttercandies/flutter_smart_dialog/issues/82)
* Fix [#84](https://github.com/fluttercandies/flutter_smart_dialog/issues/84)
* Optimize route monitor, 'KeepSingle'
* Adjust default 'maskColor' config


# [4.5.x]

* Remove 'target' param(showAttach): please use 'targetBuilder' instead of 'target' param
* Optimize scalePointBuilder (showAttach)
* Optimize showAttach
* Add replaceBuilder (showAttach)
* Add onDismiss/onMask (showLoading)
* Add displayTime (show/showAttach/showLoading)
* Add SmartMaskTriggerType ([#71](https://github.com/fluttercandies/flutter_smart_dialog/issues/71))
* Fix [#72](https://github.com/fluttercandies/flutter_smart_dialog/issues/72)
* Complete [#75](https://github.com/fluttercandies/flutter_smart_dialog/issues/75): add animationBuilder(Support highly custom animation)
* Fix [#77](https://github.com/fluttercandies/flutter_smart_dialog/issues/77)
* Fix [#78](https://github.com/fluttercandies/flutter_smart_dialog/issues/78)
* Fix [#80](https://github.com/fluttercandies/flutter_smart_dialog/issues/80)
* Optimize replaceBuilder


# [4.3.x]

* Adapt to flutter 3
* Add SmartAwaitOverType
* Fix [#56](https://github.com/fluttercandies/flutter_smart_dialog/issues/56)
* Fix [#60](https://github.com/fluttercandies/flutter_smart_dialog/issues/60)
* Add SmartDialogController
* Adjust AnimationType
  * fade: FadeTransition for all positions
  * scale: All positions are ScaleTransition
  * centerFade_otherSlide: The center position is the FadeTransition, and the other positions are the SlideTransition
  * centerScale_otherSlide: The center position is the ScaleTransition, and the other positions are the SlideTransition
* Add scalePointBuilder (showAttach)
* Fix [#69](https://github.com/fluttercandies/flutter_smart_dialog/issues/69)


# [4.2.x]

* Compatible with Flutter 2.0
* Add bindWidget feature
* Add nonAnimationTypes feature
* Optimize route monitor


# [4.0.9]

* Remove 'target' param(showAttach): please use 'targetBuilder' instead of 'target' param
* Optimize scalePointBuilder (showAttach)
* Optimize showAttach
* Add replaceBuilder (showAttach)


# [4.0.5]

* Adjust AnimationType
    * fade: FadeTransition for all positions
    * scale: All positions are ScaleTransition
    * centerFade_otherSlide: The center position is the FadeTransition, and the other positions are the SlideTransition
    * centerScale_otherSlide: The center position is the ScaleTransition, and the other positions are the SlideTransition
* Add scalePointBuilder (showAttach)


# [4.0.3]

* Fix [#53](https://github.com/fluttercandies/flutter_smart_dialog/issues/53)
* Fix back event cannot close loading
* Add SmartAwaitOverType
* Fix [#56](https://github.com/fluttercandies/flutter_smart_dialog/issues/56)
* Fix [#60](https://github.com/fluttercandies/flutter_smart_dialog/issues/60)


# [4.0.0]

* Breaking Change!!! migrate doc: [3.x migrate 4.0](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/3.x%20migrate%204.0.md) | [3.x 迁移 4.0](https://juejin.cn/post/7093867453012246565)
* Major update
* Subdivided 'config', can control 'show', 'showAttach', 'showLoading', 'showToast' in more detail
* Add 'bindPage' feature, it can reasonably solve the problem of dialog jumping pages
* Now 'dismiss' can carry the return value, similar to pop and push usage
* You can use the 'permanent' param to set a permanent dialog
* The interval time that can be added between successive displays of toasts
* Loading can set the least loading time
* Add click listener for dialog mask


# [3.4.x]

* 'showToast' add 'consumeEvent' param: [#27](https://github.com/fluttercandies/flutter_smart_dialog/issues/27)
* 'dismiss' can close dialogs with duplicate tags
* Fix [#28](https://github.com/fluttercandies/flutter_smart_dialog/issues/28)
* Fix [#42](https://github.com/fluttercandies/flutter_smart_dialog/issues/42)
* Fix [#34](https://github.com/fluttercandies/flutter_smart_dialog/issues/41) [#41](https://github.com/fluttercandies/flutter_smart_dialog/issues/34)
* Add SmartStatus.allToast


# [3.3.x]

* Notice: 'antiShake' renamed 'debounce'
* Add use System dialog feature
* Solve the page jump scene on the dialog (useSystem)
* SmartStatus add status：custom，attach，allCustom
* The entry 'init' method can customize the default style of Toast and Loading
* Optimize toast：The toast no longer consumes touch events
* Add SmartStatus.smart
* Fixed the problem that the top-of-stack dialog would be closed if the tags did not match


# [3.2.x]

* Major update！
* Add 'showAttach' feature
* Support positioning widget, display the specified location dialog
* Support highlight feature，dissolve the specified location mask
* Optimize 'keepSingle' feature


# [3.1.x]

* 'show' method add 'keepSingle' function
* Optimize dismiss method


# [3.0.x]

* Support dialog stack，close the specified dialog
* support open multi dialog
* Monitor back and pop event, then close dialog reasonably
* Initialization is more concise
* Add debounce feature
* Add close all dialog status
* Adjustment comment
* Add four toast display logic
* Compatible with cupertino style
* Increase showToast's external exposure param


# [2.3.x]

* optimize function
* solve problem of keyboard shelter toast
* optimize toast. remove isDefaultDismissType api


# [2.1.x]

* reconstruction of the underlying logic
* adjust toast default duration
* add maskWidget param


# [2.0.x]

* migrate null-safety
* adapt flutter 2.0


# [1.3.x]

* Improve toast display
* Improve toast customization function


# [1.2.x]

* loadingDialog perfect parameter settings
* adjust and use show method
* add dismiss callback


# [1.1.x]

* simplified use
* fix bug, adjust the default value of clickBgDismiss attribute to true


# [1.0.x]

* improve the usage details in the document
* perfect some function


# [0.1.x]

* perfect description
* short description
* perfect description
* adjust code of example
* add example
* remove some constructors
* property debugging is complete


# [0.0.x]

* dealing with the problem of package name
* init