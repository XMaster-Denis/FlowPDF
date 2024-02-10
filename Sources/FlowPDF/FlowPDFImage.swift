import UIKit

public class FlowPDFImage:FlowPDFContentProtocol {
    
    public var generator: FlowPDF?{
        didSet {
            guard let pdfGen = generator else {return}
            
            let targetSize = CGSize(width: getWidthContent(), height: getHeightContent())
            image = image.scalePreservingAspectRatio(
                targetSize: targetSize
            )
            widthContent = image.size.width
            heightContent = image.size.height
            availableCanvasSize = .init(width: widthContent, height: heightContent)
            sizeObject = availableCanvasSize
            if nextYPosition + sizeObjectWithMargin.height > pdfGen.pageSizeWithoutMargin.height {
                nextYPosition = 0
                pdfGen.addNewPage()
            }
            
            objectBounds = .init(origin: .init(x: marginLeft + pdfGen.margins.left,
                                               y: marginTop + pdfGen.margins.top + nextYPosition), size: sizeObject)
            
        }
    }
    
    public var nextCommand: PDFContentCommand = .none
    public var ignoreYOffset: Bool = false
    public var sizeObject: CGSize = .zero
    public var sizeObjectWithMargin: CGSize {
        CGSize.init(width: self.sizeObject.width + self.marginLeft + self.marginRight,
                    height: self.sizeObject.height + self.marginTop + self.marginBottom)
    }
    public var objectBounds: CGRect = .zero
    public var availableCanvasSize: CGSize = .zero
    public var marginTop: CGFloat = 0
    public var marginBottom: CGFloat = 0
    public var marginLeft: CGFloat = 0
    public var marginRight: CGFloat = 0
    public var widthContent: CGFloat = 0
    public var heightContent: CGFloat = 0
    public var nextYPosition: CGFloat = 0.0
    
    var image: UIImage

    public func addToContent(drawContext: CGContext) -> PDFContentCommand  {
        guard let pdfGen = generator else {return nextCommand}
        drawContext.saveGState()
        let objRect = CGRect(x: marginLeft + pdfGen.margins.left,
                             y: marginTop + pdfGen.margins.top + nextYPosition,
                             width: widthContent,
                             height: heightContent)
        image.draw(in: objRect)
        drawContext.restoreGState()
        return nextCommand
    }
    
    public init(_ image: UIImage) {
        self.image = image
    }
    
    
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
