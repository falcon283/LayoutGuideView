//
//  LayoutGuideView.swift
//  LayoutGuideView
//
//  Created by Gabriele Trabucco on 06/09/2018.
//  Copyright © 2018 Gabriele Trabucco. All rights reserved.
//

import Foundation

/**
 Using Autolayout it's really common to use dummy/spacing views to achieve a specific Layout.
 Dummy views come in help when you want to add a constraint relationship between empty spaces.
 It's totally fine to use dummy/spacing views but when they are too many on the hierarchy the rendering process
 may slow down. `UILayoutGuide` comes in help because it allows you to set constraints avoiding the view overhead.

 Because it's not possible to place UILayoutGuide directly from Interface Builder as Xcode out of the box feature,
 `LayoutGuideView` allows you to place `UILayoutGuide` as any dummy/spacing view. The dummy view will be replaced
 at runtime using a carbon copy `UILayoutGuide` moving all the dummy/spacing view constraints to the `UILayoutGuide`.

 Just place any `LayoutGuideView` you like on IB, with the relatives constraints, and it will be replaced by a
 twin `UILayoutGuide` at runtime.

 - Warning
    Do not use `LayoutGuideView` inside a `UIStackView`. **A fatal error will be raised**.

 - Warning
    Do not embed any subviews in `LayoutGuideView` using IB. **A fatal error will be raised**. You will be tempted
    in order to use the `LayoutGuideView` as a dummy layout container. Just don't, place the view in the superview
    and align it to the `LayoutGuideView` as you need.

 - Note
    You can't instanciate a `LayoutGuideView` programmatically due to it's goal is to be used from IB.
    If you need so just use a plain `UILayoutGuide`
 */
public final class LayoutGuideView: UIView {

    /// The name you can use to identify the Generated UILayoutGuide.
    @IBInspectable
    public internal(set) var name: String?

    /// The guide that will replace the placeholder view.
    private let guide = UILayoutGuide()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("Programmatically initialization is not supported. This class is only suitable for initialization by nib or storyboard")
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        guide.identifier = [String(describing: type(of: self)),
                            name.map { "\($0)" }]
            .compactMap { $0 }
            .joined(separator: "-")
    }

    public override func addSubview(_ view: UIView) {
        fatalError("You can't add subviews to a LayouGuideView. Please move the subviews out of it.")
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let superview = newSuperview else { return }
        if superview is UIStackView {
            fatalError("LayoutGuideView inside StackView is not allowed")
        } else if superview.layoutGuides.contains(guide) == false {
            newSuperview?.addLayoutGuide(guide)
        }
    }

    public override func updateConstraints() {

        if let superview = superview {
            replaceConstraints(constraints)
            replaceConstraints(superview.constraints)
            removeFromSuperview()
        }

        super.updateConstraints()
    }

    private func replaceConstraints(_ constraints: [NSLayoutConstraint]) {

        let replacements: (active: [LayoutGuideViewConstraint], inactive: [LayoutGuideViewConstraint]) = constraints.reduce((active: [], inactive: [])) {
            guard var item = $1.firstItem else { return $0 }
            let attribute = $1.firstAttribute
            let relatedBy = $1.relation
            var toItem = $1.secondItem
            let secondAttribute = $1.secondAttribute
            let multiplier = $1.multiplier
            let constant = $1.constant

            switch (item, toItem) {
            case let (i as LayoutGuideView, t as LayoutGuideView) where i === self || t === self:
                item = i.guide
                toItem = t.guide
            case let (i as LayoutGuideView, _) where i === self:
                item = i.guide
            case let (_, t as LayoutGuideView) where t === self:
                toItem = t.guide
            default:
                return $0
            }

            let replacement = LayoutGuideViewConstraint(item: item, attribute: attribute,
                                                        relatedBy: relatedBy,
                                                        toItem: toItem, attribute: secondAttribute,
                                                        multiplier: multiplier, constant: constant)

            if $1.isActive {
                return ($0.active + [replacement], $0.inactive)
            } else {
                return ($0.active, $0.inactive + [replacement])
            }
        }

        NSLayoutConstraint.activate(replacements.active)
        NSLayoutConstraint.deactivate(replacements.inactive)
    }
}

private final class LayoutGuideViewConstraint: NSLayoutConstraint { }
