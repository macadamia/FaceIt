//
//  ViewController.swift
//  FaceIt
//
//  Created by Neil White on 27/12/16.
//  Copyright © 2016 Neil White. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {
    var expression = FacialExpression(eyes: .Closed, eyeBrows: .Furrowed, mouth: .Smile) {
        didSet {
            updateUI()
        }
    }
    
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView, action: #selector(FaceView.changeScale(recogniser:))
            ))
            let happierSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.increaseHappiness))
            happierSwipeGestureRecogniser.direction = .down
            faceView.addGestureRecognizer(happierSwipeGestureRecogniser)
            let saddererSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.decreaseHappiness))
            saddererSwipeGestureRecogniser.direction = .up
            faceView.addGestureRecognizer(saddererSwipeGestureRecogniser)
            // ADDED AFTER LECTURE 5
            faceView.addGestureRecognizer(UIRotationGestureRecognizer(
                target: self, action: #selector(FaceViewController.changeBrows(recogniser:))
            ))
            updateUI()
        }
    }
    
    func increaseHappiness()
    {
        expression.mouth = expression.mouth.happierMouth()
    }
    func decreaseHappiness()
    {
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    @IBAction func toggleEyes(_ recogniser: UITapGestureRecognizer) {
        if recogniser.state == .ended {
            switch expression.eyes {
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            case .Squinting: break
            }
        }
    }

    // ADDED AFTER LECTURE 5
    // gesture handler to change the Model's brows with a rotation gesture
    func changeBrows(recogniser: UIRotationGestureRecognizer) {
        switch recogniser.state {
        case .changed,.ended:
            if recogniser.rotation > CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreRelaxedBrow()
                recogniser.rotation = 0.0
            } else if recogniser.rotation < -CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreFurrowedBrow()
                recogniser.rotation = 0.0
            }
        default:
            break
        }
    }
 
    //create dictionary to hold doubles for mouth curvatures
    private var mouthCurvatures = [FacialExpression.Mouth.Frown:-1.0,.Grin:0.5, .Smile:1.0, .Smirk:-0.5,.Neutral:0.0]
    private var eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed:0.5, .Furrowed:-0.5,.Normal:0.0]
    private func updateUI() {
        if faceView != nil {
            switch expression.eyes {
            case .Open: faceView.eyesOpen = true
            case .Closed: faceView.eyesOpen = false
            case .Squinting: faceView.eyesOpen = false
            }
            faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0 // ?? is a default in case it returns a nil
            faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
        }
    }
}

