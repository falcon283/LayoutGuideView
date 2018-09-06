//
//  LayoutGuideView.swift
//  LayoutGuideView
//
//  Created by Gabriele Trabucco on 06/09/2018.
//  Copyright © 2018 Gabriele Trabucco. All rights reserved.
//

import Foundation

public class LayoutGuideView: UIView {

    private let guide: UILayoutGuide = {
        let guide = UILayoutGuide()
        guide.identifier = "Generated-by-LayoutGuideView"
        return guide
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("Programmatically initialization is not supported. This class is only suitable for initialization by nib or storyboard")
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

        let replacements: (active: [NSLayoutConstraint], inactive: [NSLayoutConstraint]) = constraints.reduce((active: [], inactive: [])) {
            guard var item = $1.firstItem else { return $0 }
            let attribute = $1.firstAttribute
            let relatedBy = $1.relation
            var toItem = $1.secondItem
            let secondAttribute = $1.secondAttribute
            let multiplier = $1.multiplier
            let constant = $1.constant

            switch (item, toItem) {
            case let (i as LayoutGuideView, t as LayoutGuideView):
                item = i.guide
                toItem = t.guide
            case let (i as LayoutGuideView, _):
                item = i.guide
            case let (_, t as LayoutGuideView):
                toItem = t.guide
            default:
                return $0
            }

            let replacement = NSLayoutConstraint(item: item, attribute: attribute,
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
