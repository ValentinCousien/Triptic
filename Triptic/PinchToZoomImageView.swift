//
//  PinchToZoomImageView.swift
//  PinchToZoomImageView
//
//  Created by Josh Sklar on 5/9/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

open class PinchToZoomImageView: UIImageView {
    
    fileprivate var pinchGestureRecognizer: UIPinchGestureRecognizer?
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var rotateGestureRecognizer: UIRotationGestureRecognizer?
    fileprivate var isResetting = false

    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            self.isUserInteractionEnabled = isPinchable
            gestureRecognizers?.forEach { $0.isEnabled = isPinchable }
            self.gestureRecognizers?.forEach { $0.isEnabled = isPinchable }
        }
    }

    var scrollViewsScrollEnabled: [UIScrollView : Bool] = [:]
    
    let minimumPinchScale: CGFloat = 0.1
    var imagePosition : CGPoint = CGPoint(x: 0, y: 0)
    var imageRotate : CGFloat = 0
    var imageScale: CGFloat = 1.0 {
        didSet {
            if oldValue <= 1.0 && imageScale > 1.0 {
                disableSuperviewScrolling()
                moveImageViewCopyToWindow()
                // Transfer all touch gesture recognizers to the imageViewCopy
                gestureRecognizers?.forEach { [weak self] in
                    self?.addGestureRecognizer($0)
                }
            }
            else if oldValue > 1.0 && imageScale <= 1.0 {
                //resetSuperviewScrolling()
                //resetImageViewCopyPosition()
            }
        }
    }
    
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
    
    public func reset() {
    
        self.transform = .identity
        self.imageScale = 1.0
        self.imageRotate = 0
    }
    
    deinit {
        
    }
    
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
        
        let newScale = imageScale * recognizer.scale
        
        // Don't allow pinching to smaller than the original size
        guard newScale > minimumPinchScale else {
            return
        }
        
        imageScale = newScale
        
        let newTransform = recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale) ?? .identity
        recognizer.view?.transform = newTransform
        recognizer.scale = 1
    }
    
    @objc private func didPanImage(_ recognizer: UIPanGestureRecognizer) {
        guard imageScale > minimumPinchScale else {
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
        guard imageScale > minimumPinchScale else {
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
