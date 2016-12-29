//
//  FaceView.swift
//  FaceIt
//
//  Created by Neil White on 27/12/16.
//  Copyright © 2016 Neil White. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable  //normally Swift would infer these types but 'cos we are using @IBInspectable that have to be typed
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() }}
    
    @IBInspectable
    var mouthCurvature: Double = 0.75 { didSet { setNeedsDisplay() }} // 1 full smile, -1 full frown
    @IBInspectable
    var eyesOpen: Bool = false { didSet { setNeedsDisplay() }}
    @IBInspectable
    var eyeBrowTilt: Double = -0.75 { didSet { setNeedsDisplay() }} // -1 full furrow, 1 relaxed
    @IBInspectable
    var colour: UIColor = UIColor.blue { didSet { setNeedsDisplay() }}
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() }}
    
    // pinch gesture handler which scales the face
    func changeScale(recogniser: UIPinchGestureRecognizer) {
        switch recogniser.state {
        case .changed,.ended:
            scale *= recogniser.scale
            recogniser.scale = 1.0
        default:
            break
        }
    }

    private var skullRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    private var skullCentre: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    private struct Ratios {
        static let SkullRadiusToEyeOffset: CGFloat = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
        static let SkullRadiusToBrowOffset: CGFloat = 5
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func pathForCircleCentredAtPoint(midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath // withRadius radius is an internal name external name thing
    {
        let path = UIBezierPath(
            arcCenter: midPoint,
            radius: radius,
            startAngle: 0.0,
            endAngle: CGFloat(2*M_PI),
            clockwise: true
        )
        path.lineWidth = lineWidth
        return path
    }
    
    private func getEyeCentre(eye: Eye) -> CGPoint
    {
        let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
        var eyeCentre = skullCentre
        eyeCentre.y -= eyeOffset
        switch eye {
        case .Left: eyeCentre.x -= eyeOffset
        case .Right: eyeCentre.x += eyeOffset
        }
        return eyeCentre
        
    }
    
    private func pathForEye(eye: Eye) -> UIBezierPath
    {
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let eyeCentre = getEyeCentre(eye: eye)
        if eyesOpen {
            return pathForCircleCentredAtPoint(midPoint: eyeCentre, withRadius: eyeRadius)
        } else {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCentre.x - eyeRadius, y: eyeCentre.y))
            path.addLine(to: CGPoint(x: eyeCentre.x + eyeRadius, y: eyeCentre.y))
            path.lineWidth = lineWidth
            return path
        }
    }
    
    private func pathForMouth() -> UIBezierPath
    {
        let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
        
        let mouthRect = CGRect(x: skullCentre.x - mouthWidth / 2, y: skullCentre.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
        let smileOffset = CGFloat(max(-1,min(mouthCurvature,1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForBrow(eye: Eye) -> UIBezierPath
    {
        var tilt = eyeBrowTilt
        switch eye {
        case .Left: tilt *= -1.0
        case .Right: break
        }
        var browCentre = getEyeCentre(eye: eye)
        browCentre.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let tiltOffset = CGFloat(max(-1, min(tilt,1))) * eyeRadius / 2
        let browStart = CGPoint(x: browCentre.x - eyeRadius, y: browCentre.y - tiltOffset)
        let browEnd = CGPoint(x: browCentre.x + eyeRadius, y: browCentre.y + tiltOffset)
        let path = UIBezierPath()
        path.move(to: browStart)
        path.addLine(to: browEnd)
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        
        colour.set()
        pathForCircleCentredAtPoint(midPoint: skullCentre, withRadius: skullRadius).stroke()
        pathForEye(eye: .Left).stroke()
        pathForEye(eye: .Right).stroke()
        pathForMouth().stroke()
        pathForBrow(eye: .Left).stroke()
        pathForBrow(eye: .Right).stroke()

    }
}
