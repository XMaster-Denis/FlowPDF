import UIKit

public protocol FlowPDFContentProtocol: AnyObject {
    var generator: FlowPDF? {get set}
    var ignoreYOffset: Bool  {get set}
    var sizeObject: CGSize {get}
    var sizeObjectWithMargin: CGSize {get}
    var availableCanvasSize: CGSize {get set}
    var marginTop: CGFloat {get set}
    var marginBottom: CGFloat {get set}
    var marginLeft: CGFloat {get set}
    var marginRight: CGFloat {get set}
    var nextYPosition: CGFloat {get set}
    var widthContent: CGFloat {get set}
    var heightContent: CGFloat {get set}
    var objectBounds: CGRect {get set}
    var nextCommand: PDFContentCommand {get set}
    
    
    func addToContent(drawContext: CGContext) -> PDFContentCommand 
    func getWidthContent() -> CGFloat
    func getHeightContent() -> CGFloat
}

extension FlowPDFContentProtocol {
    public func getWidthContent() -> CGFloat{
        guard let pdfGen = generator else {return 0}
        return widthContent.isZero ? pdfGen.pageSizeWithoutMargin.width - marginLeft - marginRight: widthContent
    }
    public func getHeightContent() -> CGFloat{
        guard let pdfGen = generator else {return 0}
        return heightContent.isZero ? pdfGen.pageSizeWithoutMargin.height : heightContent
    }
}

public enum PDFContentCommand {
    case none
    case newPage
}

