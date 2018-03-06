//
//  DraggableImageView.swift
//  Triptic
//
//  Created by Valentin COUSIEN on 05/03/2018.
//  Copyright © 2018 Valentin COUSIEN. All rights reserved.
//

import Foundation
import UIKit

class DraggableImageView: UIImageView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .blue
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = .green
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let position = touches.first?.location(in: superview){
            center = position
        }
    }
}
