//
//  CanvasViewController.swift
//  Canvas
//
//  Created by Grace Qi on 2/17/16.
//  Copyright © 2016 Grace Qi. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    
    @IBAction func didPanTray(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(trayView)
        let velocity = sender.velocityInView(trayView)
        
        if sender.state == UIGestureRecognizerState.Began {
            trayOriginalCenter = trayView.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            //don't let user drag outside tray bounds
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.y > 0 {
                //snap down
                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                    self.trayView.center = self.trayDown
                    }, completion: { (Bool) -> Void in
                        
                })
                
            } else if velocity.y < 0 {
                //snap up
                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                    self.trayView.center = self.trayUp
                    }, completion: { (Bool) -> Void in
                        
                })
                
            }
        }
    }
    
    @IBAction func didPanFace(sender: AnyObject) {
        let faceTranslation = sender.translationInView(view)
        if sender.state == UIGestureRecognizerState.Began {
            var imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            
            pickupFace(newlyCreatedFace)
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + faceTranslation.x, y: newlyCreatedFaceOriginalCenter.y + faceTranslation.y)
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            dropFace(newlyCreatedFace)
        }
        
        var newFacePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onNewFacePan:")
        newlyCreatedFace.userInteractionEnabled = true
        newlyCreatedFace.addGestureRecognizer(newFacePanGestureRecognizer)
        
        var pinchFaceGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onNewFacePinch:")
        newlyCreatedFace.addGestureRecognizer(pinchFaceGestureRecognizer)
        pinchFaceGestureRecognizer.delegate = self
        
        var rotateFaceGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "onNewFaceRotate:")
        newlyCreatedFace.addGestureRecognizer(rotateFaceGestureRecognizer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }

    
    func onNewFacePinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
        } else if sender.state == UIGestureRecognizerState.Changed {
            // need to fix -- make sure that when you resize down the 2nd time, it doesn't become super small suddenly
            
            newlyCreatedFace.transform = CGAffineTransformMakeScale(scale, scale)
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
    }
    
    func onNewFaceRotate(sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.transform = CGAffineTransformRotate(newlyCreatedFace.transform, rotation)
            print("rotating")
        }
    }
    
    func onNewFacePan(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(view)
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            pickupFace(newlyCreatedFace)
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            dropFace(newlyCreatedFace)
        }
    }
    
    func pickupFace (faceImage: UIImageView) {
        if faceImage.frame.width == 60 {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                faceImage.transform = CGAffineTransformMakeScale(1.3, 1.3)
            })
        }
        

    }
    
    func dropFace (faceImage: UIImageView) {
        if faceImage.frame.width == 78 {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                faceImage.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: { (Bool) -> Void in
                    
            })
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayDownOffset = 160
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
