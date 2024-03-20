//
//  HalfScreenPresentationController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 13.03.2024.
//

import UIKit

class HalfScreenPresentationController: UIPresentationController {

    private var overlayView: UIView!
    private var topLineView: UIView!

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }

        let height = containerView.bounds.height / 2.0
        let width = containerView.bounds.width
        let origin = CGPoint(x: 0, y: containerView.bounds.height - height)

        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }

        // Add an overlay view to darken the first view controller
        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Adjust the alpha as needed
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(overlayView)

        overlayView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }

        // Add the top line view
        topLineView = UIView()
        topLineView.backgroundColor = .gray
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topLineView)

        topLineView.snp.makeConstraints { make in
            make.top.equalTo(containerView)
            make.leading.trailing.equalTo(containerView)
            make.height.equalTo(1) // Adjust the height of the line as needed
        }

        presentedView.frame = frameOfPresentedViewInContainerView
        containerView.addSubview(presentedView)

        presentedView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        UIView.animate(withDuration: 0.5, animations: {
            presentedView.transform = CGAffineTransform.identity
        })

        // Add any additional animations or transitions as needed
    }
}
