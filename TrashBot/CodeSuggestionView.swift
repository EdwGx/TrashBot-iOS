//
//  CodeSuggestionView.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-24.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

protocol CodeSuggestionViewDelegate {
    func editingEndInCodeSuggestionView(view: CodeSuggestionView)
}

class CodeSuggestionView: UIView {
    let doneButton = UIButton(type: .Custom)
    
    var delegate: CodeSuggestionViewDelegate?
    
    override init(var frame: CGRect) {
        frame.size.height = 44
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0.7333, green: 0.7608, blue: 0.7843, alpha: 1.0)
        
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.addTarget(self, action: Selector("doneButtonPressed:"), forControlEvents: [.TouchUpInside])
        
        addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: -20.0))
    }
    
    func doneButtonPressed(button: UIButton) {
        self.delegate?.editingEndInCodeSuggestionView(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
