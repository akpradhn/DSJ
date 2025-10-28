import UIKit
import SwiftUI

enum PDFGenerator {
    static func generatePatientPDF(patient: Patient) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let title = "Vaccination Record"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20)
            ]
            title.draw(at: CGPoint(x: 36, y: 36), withAttributes: attrs)

            let info = """
            Patient: \(patient.displayName)
            DOB: \(DateHelpers.formatDate(patient.dob))
            Weight: \(Formatters.grams(Int(patient.birthWeightGrams))), Length: \(patient.lengthCm) cm, Head: \(String(format: "%.1f", patient.headCircumferenceCm)) cm
            """
            let infoAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
            info.draw(in: CGRect(x: 36, y: 70, width: pageRect.width - 72, height: 100), withAttributes: infoAttrs)

            var y = 160.0
            let header = "Vaccine Schedule"
            header.draw(at: CGPoint(x: 36, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            y += 24

            for dose in patient.sortedDoses {
                let line = "\(DateHelpers.shortDate(dose.scheduledDate))  \(dose.vaccine?.name ?? "-")  [\(statusText(dose.status))]"
                line.draw(in: CGRect(x: 36, y: y, width: pageRect.width - 72, height: 16), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                y += 16
                if y > pageRect.height - 50 {
                    ctx.beginPage()
                    y = 36
                }
            }
        }
        return data
    }

    private static func statusText(_ status: DoseStatus) -> String {
        switch status {
        case .given(let date): return "Given \(DateHelpers.shortDate(date))"
        case .upcoming(let d): return "Upcoming in \(d)d"
        case .overdue(let d): return "Overdue \(d)d"
        case .notGiven: return "Not given"
        }
    }
}


