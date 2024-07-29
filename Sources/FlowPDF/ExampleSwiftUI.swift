import SwiftUI
import PDFKit
//import FlowPDF

struct PDFGeneratorFromFlowView: UIViewRepresentable {

    func makeUIView(context: Context) -> PDFView {
        let pdfGenerator = FlowPDF(paper: .A4_portrait)
        
        // Default margins for pages on all sides are 20
        pdfGenerator.margins.left = 30
        pdfGenerator.margins.right = 30
        
        // Create a regular large headline
        let title = FlowPDFText("Example title for a document")

        title.marginBottom = 20 // Add some padding at the bottom
        // Center it and increase the font size
        title.paragraphStyle.alignment = .center
        title.fontOfText = .init(name: "Arial", size: 24)!
        // After configuring the object, we will add it to the vpvp class object.
        // Depending on the sequential addition of these objects, the content will be displayed on the pages.
        // It makes no difference when to add them immediately after the configuration or all of them at the end.
        pdfGenerator.insertItem(title)
        
        
        let title2 = FlowPDFText("Here we will place information that should be placed on the right side of the page. For example, full name, position, etc.")
        title2.fontOfText = .italicSystemFont(ofSize: 18)
        // You can create your own indents for each object
        title2.marginLeft = 300 // This line creates a half-page indent on the left
        title2.marginRight = 5
        title2.marginTop = 20
        title2.marginBottom = 20

        guard let img = UIImage(systemName: "wand.and.stars") else {fatalError()}
        let imgFlowPDF = FlowPDFImage(img)
        
        // Using this parameter, you can ignore the dimensions of the previous object and place it, for example, on the same line as the previous object.
        imgFlowPDF.ignoreYOffset = true
        
        // We can set the dimensions of an object by specifying the desired values.
        imgFlowPDF.heightContent = 150
        imgFlowPDF.widthContent = 150
        
        
        let title3 = FlowPDFText("For example, let's add regular text here. Let's say we want to align it in width. The following example will show how to use a full-fledged object of the class AttributedString as text")
        title3.paragraphStyle.alignment = .justified
        title3.fontOfText = .init(name: "Arial", size: 14)!
        
        
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 14.0)! ]
        let myAttributedString = NSMutableAttributedString(string: "Last name First name", attributes: myAttribute )
        let attrString = NSAttributedString(string: " Position      ______________________________")
        myAttributedString.append(attrString)
        var myRange = NSRange(location: 17, length: 5)
        myAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: myRange)
        myRange = NSRange(location: 3, length: 17)
        let anotherAttribute = [ NSAttributedString.Key.backgroundColor: UIColor.yellow ]
        myAttributedString.addAttributes(anotherAttribute, range: myRange)
        
        let title4 = FlowPDFText(myAttributedString)
        title4.marginTop = 40
        
        // We insert all previous objects into the PDF file
        pdfGenerator.insertItem(title2)
        pdfGenerator.insertItem(imgFlowPDF)
        pdfGenerator.insertItem(title3)
        pdfGenerator.insertItem(title4)

        
        // Add an image with a signature
        guard let signature = UIImage(systemName: "signature") else {fatalError()}

        let pdfSignature = FlowPDFImage(signature)
        pdfSignature.ignoreYOffset = true
        pdfSignature.heightContent = 75
        pdfSignature.widthContent = 75
        pdfSignature.marginLeft = 300
        pdfGenerator.insertItem(pdfSignature)
        
        let your_signatureText = FlowPDFText("Your signature")
        your_signatureText.marginTop = 0
        your_signatureText.marginLeft = 280
        your_signatureText.marginBottom = 20 // Let's add an indent below after this line
        pdfGenerator.insertItem(your_signatureText)
        
        
        let tableTitle = FlowPDFText("Let's work with tabular data")
        
        tableTitle.fontOfText = .boldSystemFont(ofSize: 24)
        tableTitle.paragraphStyle.alignment = .center
        tableTitle.marginBottom = 20
        tableTitle.marginTop = 20
        pdfGenerator.insertItem(tableTitle)
        
        
        pdfGenerator.insertItem(FlowPDFText("The trick of this library is that we don’t need to think about the size of the previous object and we can add objects one by one. The library itself will create a new PDF sheet if necessary, or split the table into rows between sheets."))
        
        // The table is formed row by row. To create a string, we create an instance of the FlowPDFTable class. You can pass both an array of strings and an array of FlowPDFContentProtocol elements (that is, FlowPDFText or FlowPDFImage) to the initializer. The number of elements determines the number of columns. We pass an array of CGFloat values to the widthCollumns parameter, which indicates the sizes of each column. The total sum of these values should be 100. In our example, [10, 70, 20] means that 10% of the available space is allocated to the first column, 70% to the second column, and 20% to the third column.
        
        let headers = ["#", "Products", "Price (Including shipping and taxes)"]
        let widthCollumns: [CGFloat] = [10, 70, 20]

        let firstRow = FlowPDFTable(headers, widthCollumns: widthCollumns)
        firstRow.marginTop = 60
        firstRow.marginRight = 20
        firstRow.marginLeft = 20
        
        // The alignment of elements in a cell is carried out through the collAlignment array of the FlowPDFTable object. Default left alignment.
        firstRow.collAlignment[1] = .center
        firstRow.collAlignment[2] = .right
        firstRow.setLineWidth = 5 // Here we indicate the thickness of the lines. Default 3
        
        pdfGenerator.insertItem(firstRow)
        
        
        
        
        
        
        let products = [["01", "Bread", "$ 1.00"],
                   ["02", "Milk", "$ 1.50"],
                   ["03", "Water (But the water is not ordinary, but with a very long name. And for this reason the cell size will be increased.)", "$ 2.00"]]
        
        // Looping through the array, we add all the rows of the table to the PDF
        products.forEach { row in
            let tableRow = FlowPDFTable(row, widthCollumns: widthCollumns)
            tableRow.marginRight = 20
            tableRow.marginLeft = 20
            tableRow.setLineWidth = 2
            pdfGenerator.insertItem(tableRow)
        }
        
        
        // Add a line with the total
        let total = ["Total of products", "$ 4.50"]
        let totalWidthCollumns: [CGFloat] = [80, 20]
        let totalTableRow = FlowPDFTable(total, widthCollumns: totalWidthCollumns, newFont: .boldSystemFont(ofSize: 20))
        totalTableRow.marginRight = 20
        totalTableRow.marginLeft = 20
        totalTableRow.marginBottom = 0
        totalTableRow.setLineWidth = 4
        totalTableRow.paddingCell = 10 // Specifying the indent for the cell
        pdfGenerator.insertItem(totalTableRow)
        

        guard let figurebasketball = UIImage(systemName: "figure.basketball") else {fatalError()}
        guard let figurepoolswim = UIImage(systemName: "figure.hockey") else {fatalError()}
        guard let figuresailing = UIImage(systemName: "figure.sailing") else {fatalError()}
        
        
        let pdfImgbasketball = FlowPDFImage(figurebasketball)
        pdfImgbasketball.heightContent = 50
        pdfImgbasketball.widthContent = 50
        
        let pdfImgpoolswim = FlowPDFImage(figurepoolswim)
        pdfImgpoolswim.heightContent = 50
        pdfImgpoolswim.widthContent = 50
        
        let pdfImgsailing = FlowPDFImage(figuresailing)
        pdfImgsailing.heightContent = 50
        pdfImgsailing.widthContent = 50
        

        
        let serviceRows: [[FlowPDFContentProtocol]] = [
            [FlowPDFText("04"), FlowPDFText("Basketball"), pdfImgbasketball, FlowPDFText("$ 10.0")],
            [FlowPDFText("05"), FlowPDFText("Poolswim"), pdfImgpoolswim, FlowPDFText("$ 15.0")],
            [FlowPDFText("06"), FlowPDFText("Sailing"), pdfImgsailing, FlowPDFText("$ 20.0")]
        ]
        
        let widthCollumnsServices: [CGFloat] = [10, 40, 30, 20]
        serviceRows.forEach { row in
            let tableServiceRow = FlowPDFTable(row, widthCollumns: widthCollumnsServices)
            tableServiceRow.marginTop = 0
            tableServiceRow.marginRight = 20
            tableServiceRow.marginLeft = 20
            tableServiceRow.setLineWidth = 2
            tableServiceRow.collAlignment[2] = .center
            tableServiceRow.collAlignment[1] = .center
            
            pdfGenerator.insertItem(tableServiceRow)
        }

        
        let titleEnd = FlowPDFText("End of page")
        titleEnd.marginTop = 20
        pdfGenerator.insertItem(titleEnd)

        let pdfData = pdfGenerator.create()
        
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: pdfData)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        
    }
    
}


#Preview {
    PDFGeneratorFromFlowView()
}
