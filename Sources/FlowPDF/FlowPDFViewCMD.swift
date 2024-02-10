import UIKit

public class FlowPDFViewCMD: FlowPDFContentProtocol {
    
    public var generator: FlowPDF?

    public var nextCommand: PDFContentCommand = .none
    public var ignoreYOffset: Bool = false
    public var sizeObject: CGSize = .zero
    public var sizeObjectWithMargin: CGSize = .zero
    public var availableCanvasSize: CGSize = .zero
    public var marginTop: CGFloat = 0
    public var marginBottom: CGFloat = 0
    public var marginLeft: CGFloat = 0
    public var marginRight: CGFloat = 0
    public var nextYPosition: CGFloat = 0
    public var widthContent: CGFloat = 0
    public var heightContent: CGFloat = 0
    public var objectBounds: CGRect = .zero
    public func addToContent(drawContext: CGContext) -> PDFContentCommand {
        return nextCommand
    }
    
    init(_ cmd: PDFContentCommand) {
        self.nextCommand = cmd
    }
    
    
}
