//
//  PinchToZoomImageView.swift
//  PinchToZoomImageView
//
//  Created by Josh Sklar on 5/9/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

open class PinchToZoomImageView: UIImageView {
    
    /**
     Internal property that is a copy of the original image view.
     This is the view that gets transformed and adjusted
     while pinching/panning/rotating.
     */

    // MARK: Gesture Recognizers
    
    fileprivate var pinchGestureRecognizer: UIPinchGestureRecognizer?
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var rotateGestureRecognizer: UIRotationGestureRecognizer?
    
    /**
     Internal property to determine if the PinchToZoomImageView is currently
     resetting. Helps to prevent duplicate resets simultaneously.
     */
    fileprivate var isResetting = false

    /**
     Whether or not the image view is pinchable.
     Set this to `false` in order to completely disable pinching/panning/rotating
     functionality.
     Defaults to `true`.
     */
    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            self.isUserInteractionEnabled = isPinchable
            gestureRecognizers?.forEach { $0.isEnabled = isPinchable }
            self.gestureRecognizers?.forEach { $0.isEnabled = isPinchable }
        }
    }
    
    // MARK: UIImageView overrides
    
    // MARK: Pinch management
    
    /**
     Internal property that helps manages the `isScrollEnabled` properties of
     all superviews that are a UIScrollView.
     
     When pinching begins, any superview in the view heirarchy that is a
     UIScrollView will have its `isScrollEnabled` property set to `false` to
     disable simultaneous views scrolling.
     When pinching ends, all of their `isScrollEnabled` properties are restored
     to their initial values.
     */
    private var scrollViewsScrollEnabled: [UIScrollView : Bool] = [:]
    
    /**
     Internal property that represents the minimum scale that can be
     pinched/panned/rotated.
     
     Pinching/panning/rotating below this scale factor is disabled.
     */
    private let minimumPinchScale: CGFloat = 0.1
    
    private var imageViewCopyScale: CGFloat = 1.0 {
        didSet {
            if oldValue <= 1.0 && imageViewCopyScale > 1.0 {
                disableSuperviewScrolling()
                moveImageViewCopyToWindow()
                // Transfer all touch gesture recognizers to the imageViewCopy
                gestureRecognizers?.forEach { [weak self] in
                    self?.addGestureRecognizer($0)
                }
            }
            else if oldValue > 1.0 && imageViewCopyScale <= 1.0 {
                //resetSuperviewScrolling()
                //resetImageViewCopyPosition()
            }
        }
    }
    
    // MARK: Init
    
    private func commonInit() {
        isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchImage(_:)))
        pinchGestureRecognizer?.delegate = self
        addGestureRecognizer(pinchGestureRecognizer!)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanImage(_:)))
        panGestureRecognizer?.delegate = self
        addGestureRecognizer(panGestureRecognizer!)
        
        rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotateImage(_:)))
        rotateGestureRecognizer?.delegate = self
        addGestureRecognizer(rotateGestureRecognizer!)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }
    
    deinit {
        
    }
    
    // MARK: Helper - imageViewCopy management
    
    /**
     Loops over all superviews and for any that are a UIScrollView,
     will disable scrolling.
     
     This should be called as soon as pinching begins.
     */
    private func disableSuperviewScrolling() {
        var sv = superview
        while sv != nil {
            if let scrollView = sv as? UIScrollView {
                scrollViewsScrollEnabled[scrollView] = scrollView.isScrollEnabled
                scrollView.isScrollEnabled = false
            }
            sv = sv?.superview
        }
    }
    
    /**
     Loops over all of the scroll views that have gotten their `isScrollEnabled`
     property modified, and resets them to whatever they were before
     being modified.
     */
    private func resetSuperviewScrolling() {
        for (scrollView, isScrollEnabled) in scrollViewsScrollEnabled {
            scrollView.isScrollEnabled = isScrollEnabled
        }
        
        scrollViewsScrollEnabled.removeAll()
    }
    
    private func resetImageViewCopyPosition() {
        self.removeFromSuperview()
    }
    
    private func moveImageViewCopyToWindow() {
        
    }

    // MARK: Gesture Recognizer handlers

    @objc private func didPinchImage(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state != .ended else {
            return
        }
        
        let newScale = imageViewCopyScale * recognizer.scale
        
        // Don't allow pinching to smaller than the original size
        guard newScale > minimumPinchScale else {
            return
        }
        
        imageViewCopyScale = newScale
        
        let newTransform = recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale) ?? .identity
        recognizer.view?.transform = newTransform
        recognizer.scale = 1
    }
    
    @objc private func didPanImage(_ recognizer: UIPanGestureRecognizer) {
        guard imageViewCopyScale > minimumPinchScale else {
            return
        }
        
        guard recognizer.state != .ended else {
            return
        }
        
        let translation = recognizer.translation(in: self.superview)
        let originalCenter = self.center
        let translatedCenter = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y + translation.y)
        self.center = translatedCenter
        recognizer.setTranslation(.zero, in: self)
    }
    
    @objc private func didRotateImage(_ recognizer: UIRotationGestureRecognizer) {
        guard imageViewCopyScale > minimumPinchScale else {
            return
        }
        
        guard recognizer.state != .ended else {
            return
        }
        
        recognizer.view?.transform = recognizer.view?.transform.rotated(by: recognizer.rotation) ?? .identity
        recognizer.rotation = 0
    }
}

extension PinchToZoomImageView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
