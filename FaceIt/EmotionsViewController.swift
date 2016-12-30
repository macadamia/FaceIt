//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by Neil White on 30/12/16.
//  Copyright © 2016 Neil White. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController {

    private let emotionalFaces: Dictionary<String,FacialExpression> = [
        "Show Angry Face" : FacialExpression(eyes: .Closed, eyeBrows: .Furrowed, mouth: .Frown),
        "Show Happy Face" : FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smile),
        "Show Worried Face" : FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk),
        "Show Mischievous Face" : FacialExpression(eyes: .Open, eyeBrows: .Furrowed, mouth: .Grin)
    ]
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        //now the detail split view is in a Nav View, so we must get the diestion view from the nav controller
        if let navcon = destinationVC as? UINavigationController {
            destinationVC = navcon.visibleViewController ?? destinationVC //set to the detail of the split view or default to the original destinationVC. this allows it to work on iPhones and ipdas
        }
        if let faceVC = destinationVC as? FaceViewController {
            if let identifier = segue.identifier {
                if let expression = emotionalFaces[identifier] {
                    faceVC.expression = expression
                    if let sendingButton = sender as? UIButton{
                        faceVC.navigationItem.title = sendingButton.currentTitle
                    }
                }
            }
        }
    }

}
