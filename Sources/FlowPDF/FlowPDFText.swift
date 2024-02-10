import UIKit

public class FlowPDFText: FlowPDFContentProtocol {
    

    public var generator: FlowPDF? {
        didSet {
            guard let pdfGen = generator else {return}
            widthContent = getWidthContent()
            heightContent = getHeightContent()
            availableCanvasSize = .init(width: widthContent, height: heightContent)
            
            if !isAttributedString {
                fontStyle = [.font: fontOfText,.paragraphStyle: paragraphStyle]
                attributedText = NSAttributedString(string: text, attributes: fontStyle)
            }
            
            
            sizeObject = attributedText.boundingRect(with: availableCanvasSize,
                                                     options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                     context: nil).size
            if nextYPosition + sizeObjectWithMargin.height > pdfGen.pageSizeWithoutMargin.height {
                nextYPosition = 0
                pdfGen.addNewPage()
            }
            objectBounds = .init(origin: .init(x: marginLeft + pdfGen.margins.left,
                                               y: marginTop + pdfGen.margins.top + nextYPosition), size: sizeObject)
        }
    }

    
    public var nextCommand: PDFContentCommand = .none
    public var objectBounds: CGRect = .zero
    public var ignoreYOffset: Bool = false
    public var sizeObject: CGSize = .zero
    public var availableCanvasSize: CGSize = .zero
    public var nextYPosition: CGFloat = 0
    public var sizeObjectWithMargin: CGSize {
        CGSize.init(width: self.sizeObject.width + self.marginLeft + self.marginRight,
              height: self.sizeObject.height + self.marginTop + self.marginBottom)
    }
    
    public var marginTop: CGFloat = 0
    public var marginBottom: CGFloat = 0
    public var marginLeft: CGFloat = 0
    public var marginRight: CGFloat = 0
    public var widthContent: CGFloat = 0
    public var heightContent: CGFloat = 0
    public var fontOfText: UIFont = .boldSystemFont(ofSize: 14)
    public var paragraphStyle = NSMutableParagraphStyle()
    
    private var isAttributedString = false
    private var fontStyle: [NSAttributedString.Key: Any] = .init()
    private var attributedText: NSAttributedString = .init()
    private var textCanvas: CGSize = .zero
    var text: String = ""
    
    public init(_ text: String) {
        self.text = text
    }
    
    public init(_ attributedText: NSAttributedString) {
        isAttributedString = true
        self.attributedText = attributedText
    }
    
    public func addToContent(drawContext: CGContext) -> PDFContentCommand {
        
        guard let pdfGen = generator else {return nextCommand}
        drawContext.saveGState()
        
        let objRect = CGRect(x: marginLeft + pdfGen.margins.left,
                             y: marginTop + pdfGen.margins.top + nextYPosition,
                             width: widthContent,
                             height: heightContent)
        
        attributedText.draw(in: objRect)
        drawContext.restoreGState()
        return nextCommand
    }
    
    
    
}
