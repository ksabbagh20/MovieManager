//
//  BorderedButton.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved. Migrated to swift 5 by Karim Al Sabbagh 8/2019
//

import UIKit

let borderedButtonHeight : CGFloat = 44.0
let borderedButtonCornerRadius : CGFloat = 4.0
let padBorderedButtonExtraPadding : CGFloat = 20.0
let phoneBorderedButtonExtraPadding : CGFloat = 14.0

class BorderedButton: UIButton {
    
    // MARK: - Properties
    
    var backingColor : UIColor? = nil
    var highlightedBackingColor : UIColor? = nil
    
    // MARK: - Constructors
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Setters
    
    private func setBackingColor(backingColor : UIColor) -> Void {
        if (self.backingColor != nil) {
            self.backingColor = backingColor;
            self.backgroundColor = backingColor;
        }
    }
    
    private func setHighlightedBackingColor(highlightedBackingColor: UIColor) -> Void {
        self.highlightedBackingColor = highlightedBackingColor
        self.backingColor = highlightedBackingColor
    }
    
    // MARK: - Tracking
    
    override func beginTracking(_ touch: UITouch, with withEvent: UIEvent?) -> Bool {
        self.backgroundColor = self.highlightedBackingColor
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with withEvent: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    override func cancelTracking(with event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        _ = UIDevice.current.userInterfaceIdiom
        let extraButtonPadding : CGFloat = 14.0
        var sizeThatFits = CGSize(width: 0,height: 0)//CGSizeZero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = 44.0
        return sizeThatFits
        
    }
}
