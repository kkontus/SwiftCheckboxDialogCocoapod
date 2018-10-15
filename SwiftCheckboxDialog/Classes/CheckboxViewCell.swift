//
//  CheckboxViewCell.swift
//  Pods
//
//  Created by Kristijan Kontus on 16/12/2016.
//
//

import UIKit

open class CheckboxViewCell: UITableViewCell {
    class var identifier: String {
        return String.className(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open func setup() {
        //some default stuff
        
        fontDefault()
        self.textLabel?.textColor = UIColor.black
    }
    
    open class func height() -> CGFloat {
        return 42
    }
    
    open func fontDefault() {
        self.textLabel?.font = UIFont.systemFont(ofSize: 15)
    }
    
    open func setData(_ data: Any?) {
        if let menuText = data as? (name: String, translated: String) {
            self.textLabel?.text = menuText.translated
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.alpha = 0.4
        } else {
            self.alpha = 1.0
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


