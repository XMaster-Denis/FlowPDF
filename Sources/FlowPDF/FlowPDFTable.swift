import UIKit

public class FlowPDFTable: FlowPDFContentProtocol {

    public var generator: FlowPDF? {
        didSet {
            guard let pdfGen = generator else {return}
            widthContent = getWidthContent()
            heightContent = getHeightContent()
            
            availableCanvasSize = .init(width: widthContent, height: heightContent)
            
            sizeObject = availableCanvasSize
            
            widthColumns = widthColumns.map { item in
                return sizeObject.width*(item/100)
            }

            heightRow = getMaxRowHeight()
            sizeObject.height = heightRow
            
            if nextYPosition + sizeObjectWithMargin.height > pdfGen.pageSizeWithoutMargin.height {
                nextYPosition = 0
                pdfGen.addNewPage()
            }
            objectBounds = .init(x: marginLeft + pdfGen.margins.left,
                                 y: marginTop + pdfGen.margins.top + nextYPosition,
                                 width: widthContent,
                                 height: heightContent)

        }
    }
   
    public var nextCommand: PDFContentCommand = .none
    var headerContent: [FlowPDFContentProtocol] = []
    public var widthColumns: [CGFloat] = []
    public var collAlignment: [AlignmentCell]
    public var objectBounds: CGRect = .zero
    public var ignoreYOffset: Bool = false
    public var sizeObject: CGSize = .zero
    private var heightRow: CGFloat = 0
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
    public var paddingCell: CGFloat = 5
    public var setLineWidth: CGFloat = 3
    
    public convenience init(_ content: [String], widthCollumns: [CGFloat] = []) {
        self.init(widthCollumns: widthCollumns)
        content.forEach { str in
            self.headerContent.append(FlowPDFText(str))
        }
    }
    
    public convenience init(_ content: [String], widthCollumns: [CGFloat] = [], newFont: UIFont) {
        self.init(widthCollumns: widthCollumns)
        content.forEach { str in
            self.headerContent.append(FlowPDFText(str, fontOfText: newFont))
        }
    }
    
    public convenience init(_ content: [FlowPDFContentProtocol], widthCollumns: [CGFloat] = []) {
        self.init(widthCollumns: widthCollumns)
        self.headerContent = content
    }
    
    public init(widthCollumns: [CGFloat] = []) {
        self.collAlignment =  Array.init(repeating: .left, count: widthCollumns.count)
        self.widthColumns = widthCollumns
    }
    
    
    func getMaxRowHeight() -> CGFloat {
        guard let pdfGen = generator else {return 0}
        var maxHeightHeader: CGFloat = 0
        var startXPosition: CGFloat = marginLeft
        
        headerContent.enumerated().forEach { columnIndex, colItem in
         
            colItem.marginLeft = startXPosition + paddingCell
      
            colItem.marginTop = marginTop + paddingCell
            colItem.marginBottom = paddingCell
            colItem.widthContent = widthColumns[columnIndex] - paddingCell - paddingCell
            
            
            if let itemTextCell = colItem as? FlowPDFText {
                switch collAlignment[columnIndex] {
                case .center: itemTextCell.paragraphStyle.alignment = .center
                case .right:  itemTextCell.paragraphStyle.alignment = .right
                case .left: itemTextCell.paragraphStyle.alignment = .left
                }
            }
            
            
            
            colItem.generator = pdfGen
            maxHeightHeader = max(colItem.sizeObjectWithMargin.height, maxHeightHeader)
            
            startXPosition += widthColumns[columnIndex]
        }

        return maxHeightHeader - marginTop
    }
    
    
    public func addToContent(drawContext: CGContext) -> PDFContentCommand  {
        drawContext.saveGState()
        drawTableRowAndContent(drawContext: drawContext, bounds: objectBounds)
        drawContext.restoreGState()
        return nextCommand
    }
    
    func drawTableRowAndContent(drawContext: CGContext, bounds: CGRect) {
        guard let pdfGen = generator else {return}
        drawContext.setLineWidth(setLineWidth)

        drawContext.move(to: CGPoint(x: bounds.origin.x , y: bounds.origin.y))
        drawContext.addLine(to: CGPoint(x: bounds.width + bounds.origin.x, y: bounds.origin.y))
        
        drawContext.move(to: CGPoint(x: bounds.origin.x , y: bounds.origin.y + heightRow))
        drawContext.addLine(to: CGPoint(x: bounds.width + bounds.origin.x, y: bounds.origin.y + heightRow))
        
        drawContext.move   (to: CGPoint(x: bounds.origin.x, y: bounds.origin.y))
        drawContext.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.origin.y + heightRow))

        var tabX: CGFloat = 0
        
        widthColumns.forEach { widthColumn in
            tabX += widthColumn
            drawContext.move   (to: CGPoint(x: bounds.origin.x + tabX, y: bounds.origin.y))
            drawContext.addLine(to: CGPoint(x: bounds.origin.x + tabX, y: bounds.origin.y + heightRow))
        }

        drawContext.strokePath()
        
        headerContent.enumerated().forEach { index, item in
            item.marginTop = bounds.origin.y - pdfGen.margins.top + paddingCell
            
            if item is FlowPDFImage {
                switch collAlignment[index] {
                case .center:
                    item.marginLeft += (widthColumns[index] - (paddingCell*2)) / 2 - item.widthContent / 2
                case .right:
                    item.marginLeft += widthColumns[index] - item.widthContent - (paddingCell*2)
                case .left: break
                }
            }

            _ = item.addToContent(drawContext: drawContext)
        }
    }
}

public enum AlignmentCell {
    case left
    case center
    case right
}
