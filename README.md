## Introduction

Using Autolayout it's really common to use dummy/spacing views to achieve a specific Layout.
Dummy views come in help when you want to add a constraint relationship between empty spaces.
It's totally fine to use dummy/spacing views but when they are too many on the hierarchy the rendering process
may slow down. `UILayoutGuide` comes in help because it allows you to set constraints avoiding the view overhead.


## Problem

We as Developers would really appreciate Apple will make `UILayoutGuide` available inside Interface Builder but currently 
we can use them only programmatically.


# LayoutGuideView

Because it's not possible to place UILayoutGuide directly from Interface Builder as Xcode out of the box feature,
`LayoutGuideView` allows you to place `UILayoutGuide` as any dummy/spacing view. The dummy view will be replaced
at runtime using a carbon copy `UILayoutGuide` moving all the dummy/spacing view constraints to the `UILayoutGuide`.


## How it Works

`LayoutGuideView` works as a IB transient view that will be automatically translated into a `UILayoutGuide` at runtime.
Once the `LayoutGuideView` is dispatched from IB and added to it's superview it starts the migration process. It automatically install the `UILayoutGuide` into its superview and starts migrating the constraints it's involved in. At the end of the constraints migration process the `LayoutGuideView` is then removed from it's superview to let it die in peace ⚰️

## Installation

[CocoaPods](http://cocoapods.org/)

1. Add the following to your Podfile:

```pod 'LayoutGuideView'```

2. Integrate your dependencies using frameworks: add use_frameworks! to your Podfile.

3. Run pod install.

[Carthage](https://github.com/Carthage/Carthage)

1. Add the following to your Cartfile:

```github "falcon283/LayoutGuideView"```

2. Run carthage update and follow the steps as described in Carthage's [README](https://github.com/Carthage/Carthage/blob/master/README.md).


## How to use it

Just place a View that represent your layout guide in IB and layout it as your needs using AutoLayut Constraints. Don't forget to change the class type to `LayoutGuideView` into the _Identity Inspector_. Optionally you can set an Layout Guide name in the _Attributes Inspector_ to identify the generated `UILayoutGuide` in the list of `layoutGuides` of your superview.

There are only few simple rules to respect
1. Do not use `LayoutGuideView` as arrangedSubview of `UIStackView`. fatalError will be raised.
2. Do not embed any subview into `LayoutGuideView`. fatalError will be raised.
3. Do not allocate `LayoutGuideView` programmatically ... why you should do it? fatalError will be raised.


## FAQ

1. Why I can't use it in `UIStackView`?

Simply because `UIStackView` is a non rendering view that have its own Layout Rules as per user configuration. If you introduce other layout constraints between `arrangedSubviews` the StackView can't works as expected and the result of your layout will be unpredictable. By the way you can always create a Layout Guide inside a view that is contained in the `arrangedSubviews`.  


2. How can I use it as Dummy Layout Container if I can't embed subviews?

Well, Dummy Views are often used as Layout Container to place a certain area somewhere and then constraint the inner subview as we want. You can't do it with `LayoutGuideView` because it will vanish at some point and you will loose your subviews. What you can do is consider it as a "reference layout area" ... maybe "Safe Area" just come to your mind ;)
If you keep your "wanted" subview at the same hierarchy level of `LayoutGuideView` you can constraint it to the `LayoutGuideView` as usual with just different constraints. 
Please take a look to the Example App.

3. I could use also Relative Margins, what are the benefits of using `LayoutGuideView` in this case?

While Relative Margins are perfectly fine and you should keep using it in most cases, they have some limitations.
The  `layoutMargins` or `directionalLayoutMargins` in iOS 11 are staticaly defined and can't react the layout changes unless you change it by code.
Using `LayoutGuideView` instead, in case you need, you can define the margins in terms of AutoLayout. Think about the safe area ... it changes the "margins" automatically when you rotate your iPhone X horizontally. Using `LayoutGuideView` you can do the same because you can now define in terms of AutoLayout how the "empty space" is constrained.
