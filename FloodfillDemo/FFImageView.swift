//
//  FFImageView.swift
//  FloodfillDemo
//
//  Created by Gudkesh Kumar on 22/11/18.
//  Copyright © 2018 Gudkesh Kumar. All rights reserved.
//

import UIKit

class FFImageView: UIImageView {
    private var tolerance = 20
    private var fillColor = UIColor.red

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let tPoint = touch.location(in: self)
        let imagePoint = conevertToImagePoints(touchPoint: tPoint)
        
        let image1 = self.image?.floodFill(from: imagePoint, with: fillColor, andTolerance: tolerance)
        
        DispatchQueue.main.async {
            self.image = image1
        }
    }

}

extension FFImageView {
    func set(fillColor color: UIColor) {
        self.fillColor = color
    }
    
    private func set(image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 1) {
            let image1 = UIImage(data: data)
            self.image = image1
        }
    }
}

extension FFImageView {
    private func conevertToImagePoints(touchPoint point: CGPoint) -> CGPoint {
        var imagePoint = point
        guard let image = self.image else {
            return .zero
        }
        
        let imageSize = image.size
        let viewSize = self.bounds.size
        
        let ratioX = viewSize.width / imageSize.width
        let ratioY = viewSize.height / imageSize.height
        
        let contentMode = self.contentMode
        switch contentMode {
            
        case .scaleToFill, .redraw:
            imagePoint.x /= ratioX
            imagePoint.y /= ratioY
            
        case .scaleAspectFill, .scaleAspectFit:
            var scale: CGFloat = 0.0
            if contentMode == .scaleAspectFit {
                scale = min(ratioX, ratioY)
            } else {
                scale = max(ratioX, ratioY)
            }
            // Remove the x or y margin added in FitMode
            imagePoint.x -= (viewSize.width  - imageSize.width  * scale) / 2.0
            imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0
            
            imagePoint.x /= scale
            imagePoint.y /= scale
            
        case .center:
            
            imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0
          
        case .top:
            imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0
           
        case .bottom:
            
            imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0
            imagePoint.y -= (viewSize.height - imageSize.height)
           
        case .left:
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0
          
        case .right:
            
            imagePoint.x -= (viewSize.width - imageSize.width)
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0
           
            
        case .topRight:
            imagePoint.x -= (viewSize.width - imageSize.width)
           
        case .bottomLeft:
            imagePoint.y -= (viewSize.height - imageSize.height)
            
            
        case .bottomRight:
            imagePoint.x -= (viewSize.width - imageSize.width)
            imagePoint.y -= (viewSize.height - imageSize.height)
            
            
        case .topLeft:
            break
        }
        
        return imagePoint
    }
}
