//
//  IconsSelectionPresentationController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit

// IconsSelectionPresentationController.swift

class IconSelectionPresentationController: UIPresentationController {
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        overlayView.frame = containerView.bounds
        overlayView.alpha = 0
        containerView.addSubview(overlayView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overlayView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overlayView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        let sideLength: CGFloat = 400
        let xOffset = (containerView.bounds.width - sideLength) / 2
        let yOffset = (containerView.bounds.height - sideLength) / 2
        return CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength + 200)
    }

    func shouldRemovePresentersView() -> Bool {
        return false
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 16
        presentedView?.clipsToBounds = true
    }

    @objc func overlayViewTapped() {
        //presentedViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if completed {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapped))
            overlayView.addGestureRecognizer(tapGesture)
        }
    }
}
