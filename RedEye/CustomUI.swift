//
//  TextField.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/12/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

@IBDesignable
class TextField: UITextField {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = Constants.Colors.redColor.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 25
    }
    
    
}

@IBDesignable
class LoginButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = Constants.Colors.redColor
        self.layer.cornerRadius = 25
    }
    
    
}

@IBDesignable
class SegmentedControl: UIControl{
    
    
    private var labels = [UILabel]()
    var view = UIView()
    
    var items = ["Log in", "Sign up"]{
        didSet{
            setUpLabels()
        }
    }
    
    func setUpLabels(){
        for label in labels{
            label.removeFromSuperview()
        }
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...items.count {
            let label = UILabel(frame:CGRect.zero)
            label.text = items[index-1]
            label.textAlignment = .center
            label.textColor = Constants.Colors.redColor
            self.addSubview(label)
            labels.append(label)
        }
        
    }
    
    var selectedSegment = 0 {
        didSet {
            displayNewSelectedSegment()
        }
    }
    
    func getSelectedSegment() -> Int{
        return selectedSegment
        
    }
    
    func displayNewSelectedSegment() {
        let label = labels[selectedSegment]
        print("label \(label)")
        self.view.frame = label.frame
        print("label frame \(label.frame)")
        
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
            setUpSegment()
        
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSegment()
    }
    
    
    
    func setUpSegment(){
        layer.cornerRadius = frame.height / 2
        layer.borderColor = Constants.Colors.redColor.cgColor
        layer.borderWidth = 2
        backgroundColor = UIColor.clear
        
        setUpLabels()
        
        insertSubview(view, at: 0)
    }
    
   
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        print("location \(location)")
        var calculatedSegment: Int?
        for(index, item) in labels.enumerated(){
            if item.frame.contains(location){
                calculatedSegment = index
                print("calculated segment \(calculatedSegment)")
            }
        }
        
        if calculatedSegment != nil {
            self.selectedSegment = calculatedSegment!
            print("selectedSegment \(self.selectedSegment)")
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat (items.count)
        selectFrame.size.width = newWidth
        view.frame = selectFrame
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = view.frame.height / 2
        
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0 ... labels.count - 1 {
            var label = labels[index]
            let xPosition = CGFloat(index) * labelWidth
            label.frame = CGRect(x:xPosition, y:0 , width:labelWidth, height:labelHeight)
        }
    }
    
}
