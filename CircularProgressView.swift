//
//  ArcProgressBarView.swift
//  FireEvacuation
//
//  Created by Amritha on 25/05/23.
//

import UIKit

class CircularProgressView: UIView {
    
   fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    fileprivate func createCircularPath() {
        
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(0.75 * .pi), endAngle: CGFloat(2.25 * .pi), clockwise: true)

        let arcRadius = (frame.size.width - 1.5) / 2
        let arcCenter = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)

        let startAngle = CGFloat(0.75 * .pi)
        let endAngle = CGFloat(2.25 * .pi)

        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                   radius: arcRadius,
                                   startAngle: startAngle,
                                   endAngle: endAngle,
                                   clockwise: true)

        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")
        
    }
    
}
