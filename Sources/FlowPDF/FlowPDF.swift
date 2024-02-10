import Foundation
import PDFKit
import SwiftUI

public class FlowPDF {
    
    public var margins: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
    
    var paperSize: PaperSizes
    var pageRect: CGRect
    var pageSize: CGSize
    var pageSizeWithoutMargin: CGSize {
        .init(width: pageSize.width - margins.left - margins.right,
              height: pageSize.height - margins.top - margins.bottom)
    }
    var pdfRenderer: UIGraphicsPDFRenderer

    var pdfElements: [FlowPDFContentProtocol] = []
    
    public init(paper: PaperSizes) {
        paperSize = paper
        pageRect = CGRect(x: 0, y: 0, width: paperSize.rawValue.0, height: paperSize.rawValue.1)
        pageSize = .init(width: paperSize.rawValue.0, height: paperSize.rawValue.1)
        pdfRenderer = .init(bounds: pageRect)
    }
    
    public enum PaperSizes: RawRepresentable {
        
        case A3_portrait
        case A3_landscape
        case A4_portrait
        case A4_landscape        
        case A5_portrait
        case A5_landscape
        
        public var rawValue: (Int, Int) {
            switch self {
            case .A3_landscape: return (1191, 842)
            case .A3_portrait: return (842, 1191)
            case .A4_landscape: return (842, 595)
            case .A4_portrait: return (595, 842)
            case .A5_landscape: return (595, 420)
            case .A5_portrait: return (420, 595)
            }
        }
        
        public init?(rawValue: (Int, Int)) {
            switch rawValue {
            case (1191, 842):  self = .A3_landscape
            case (842, 1191):  self = .A3_portrait
            case (842, 595):  self = .A4_landscape
            case (595, 842):  self = .A4_portrait
            case (595, 420):  self = .A5_landscape
            case (420, 595):  self = .A5_portrait
            default: return nil
                
            }
        }
    }
    
    public func create () -> Data {
        
        let data = pdfRenderer.pdfData { content in
            content.beginPage()
            let drawContext = content.cgContext
            pdfElements.forEach { element in
               let command = element.addToContent(drawContext: drawContext)
                switch command {
                    
                case .none: break
                case .newPage:
                    content.beginPage()
                }
            }
        }
        return data
    }
    
    func addNewPage(){
        let pdfCmd = FlowPDFViewCMD(.newPage)
        pdfElements.append(pdfCmd)
    }
    
    public func insertItem(_ item: FlowPDFContentProtocol) {
        item.nextYPosition = 0
        if let lastItem = pdfElements.last {
            if item.ignoreYOffset {
                item.nextYPosition = lastItem.nextYPosition
            } else {
                item.nextYPosition = lastItem.nextYPosition + lastItem.sizeObjectWithMargin.height
            }
        }
        item.generator = self
        pdfElements.append(item)
    }

}
