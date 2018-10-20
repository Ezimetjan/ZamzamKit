//
//  PresentableView.swift
//  ZamzamKit
//  https://stackoverflow.com/q/49597822/235334
//
//  Created by Basem Emara on 2018-10-18.
//  Copyright © 2018 Zamzam. All rights reserved.
//

import UIKit

public protocol PresentableView {
    var contentView: UIView! { get }
}

public extension PresentableView where Self: UIView {
    
    /// Dismisses the control that was presented modally by the view controller.
    ///
    /// - Parameter completion: The block to execute after the control is dismissed.
    func dismiss(completion: (() -> Void)? = nil) {
        // Animate out
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.contentView.center.y += self.contentView.bounds.height
                self.layoutIfNeeded()
                self.alpha = 0
            },
            completion: { _ in
                // Deinitialize
                self.removeFromSuperview()
                completion?()
            }
        )
    }
}

public extension UIViewController {
    
    /// Presents a control modally.
    ///
    /// - Parameters:
    ///   - control: The control to display over the current view controller’s content.
    ///   - completion: The block to execute after the presentation animation finishes.
    func present<T: UIView & PresentableView>(control: T, completion: (() -> Void)? = nil) {
        // Prepare animation
        control.contentView.center.y += control.contentView.bounds.height
        control.alpha = 0
        
        // Display
        let rootView: UIView! = (navigationController?.view ?? view)
        control.frame = rootView.bounds
        control.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.addSubview(control)
        
        // Animate
        UIView.animate(withDuration: 0.2) {
            control.contentView.center.y -= control.contentView.bounds.height
            control.layoutIfNeeded()
            control.alpha = 1
            completion?()
        }
    }
}
