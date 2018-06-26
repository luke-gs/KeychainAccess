//
//  OutlinedLabel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// A label subclass that has a Font Stroke outline
/// around the text.  We can't just use attributes
/// as the font stroke is painted outside the bounds
class OutlineLabel: UILabel {
    
    open var strokeColor: UIColor = .white
    open var fillColor: UIColor   = .black
    
    open var horizontalPadding: CGFloat = 3
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.width += horizontalPadding * 2
        return size
    }
    
    // MARK: - Initializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        font            = .systemFont(ofSize: 10.0, weight: UIFont.Weight.bold)
        textColor       = .white
        textAlignment   = .center
    }
    
    override func drawText(in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        var modifiedForInsetsRect = rect
        modifiedForInsetsRect.origin.x += horizontalPadding
        modifiedForInsetsRect.size.width -= horizontalPadding
        
        ctx.setLineWidth(4)
        ctx.setLineJoin(.round)
        ctx.setTextDrawingMode(.stroke)
        textColor = strokeColor
        super.drawText(in: modifiedForInsetsRect)
        
        ctx.setTextDrawingMode(.fill)
        textColor = fillColor
        super.drawText(in: modifiedForInsetsRect)
    }
}
