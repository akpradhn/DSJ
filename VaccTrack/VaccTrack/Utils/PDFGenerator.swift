import UIKit
import SwiftUI

enum PDFGenerator {
    static func generatePatientPDF(patient: Patient) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let title = "Immunization Records"
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
                let vName = dose.vaccine?.name ?? "-"
                let optTag = VaccineOptionalHelper.isOptional(name: vName) ? " (Optional)" : ""
                let line = "\(DateHelpers.shortDate(dose.scheduledDate))  \(vName)\(optTag)  [\(statusText(dose.status))]"
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

    // Card-like sheet similar to the provided image
    static func generateCardLikePDF(patient: Patient) -> Data {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let left: CGFloat = 24
        let right: CGFloat = page.width - 24

        return renderer.pdfData { ctx in
            ctx.beginPage()

            // Header
            let title = "Immunization Records"
            title.draw(at: CGPoint(x: left, y: 24), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
            let subtitle = "\(patient.displayName)  |  DOB: \(DateHelpers.shortDate(patient.dob))"
            let para = NSMutableParagraphStyle(); para.lineBreakMode = .byWordWrapping
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: para
            ]
            // Wrap subtitle and give it ample height
            let subtitleRect = CGRect(x: left, y: 50, width: page.width - 2*left, height: 40)
            subtitle.draw(in: subtitleRect, withAttributes: subAttrs)

            // Table Columns: Age | Vaccines | Due on | Given on | Batch | Weight | Length | Head Circ.
            // Push table down to avoid overlapping with header/subtitle
            let startY: CGFloat = 110
            let rowHeight: CGFloat = 24
            // Draw header row
            drawRow(y: startY-rowHeight, texts: ["Age","Vaccine","Due on","Given on","Batch","Wt","Len","Head"], colXs: [left, left+70, left+240, left+320, left+400, left+460, left+520, right], bold: true)

            // Group by recommendedAgeInWeeks for age labels
            var y = startY
            let doses = patient.sortedDoses
            for dose in doses {
                let ageWeeks = Int(dose.vaccine?.recommendedAgeInWeeks ?? 0)
                let ageLabel: String
                if ageWeeks == 0 { ageLabel = "Birth" }
                else if ageWeeks == 52 { ageLabel = "12 Months" }
                else if ageWeeks % 52 == 0 { ageLabel = "\(ageWeeks/52) Years" }
                else if ageWeeks % 4 == 0 { ageLabel = "\(ageWeeks/4) Weeks" } else { ageLabel = "Week \(ageWeeks)" }
                let due = DateHelpers.shortDate(dose.scheduledDate)
                let given = dose.givenOn.map { DateHelpers.shortDate($0) } ?? ""
                let batch = dose.batchNumber ?? ""
                let wt = dose.weightAtDose > 0 ? String(format: "%.0f", dose.weightAtDose) : ""
                let ht = dose.heightAtDose > 0 ? String(format: "%.0f", dose.heightAtDose) : ""
                let head = dose.headCircumferenceAtDose > 0 ? String(format: "%.0f", dose.headCircumferenceAtDose) : ""
                let vName = dose.vaccine?.name ?? ""
                let optTag = VaccineOptionalHelper.isOptional(name: vName) ? " (Optional)" : ""
                drawRow(y: y, texts: [ageLabel, vName + optTag, due, given, batch, wt, ht, head], colXs: [left, left+70, left+240, left+320, left+400, left+460, left+520, right], bold: false)
                y += rowHeight
                if y > page.height - 40 { ctx.beginPage(); y = 24 }
            }
        }
    }

    private static func drawRow(y: CGFloat, texts: [String], colXs: [CGFloat], bold: Bool) {
        let font: UIFont = bold ? .boldSystemFont(ofSize: 11) : .systemFont(ofSize: 10)
        for i in 0..<texts.count {
            let x = colXs[i] + 2
            let nextX = colXs[min(i+1, colXs.count-1)] - 4
            let rect = CGRect(x: x, y: y, width: nextX - x, height: 18)
            texts[i].draw(in: rect, withAttributes: [.font: font])
        }
        // Draw grid lines
        let path = UIBezierPath()
        path.lineWidth = 0.5
        for x in colXs { path.move(to: CGPoint(x: x, y: y - 4)); path.addLine(to: CGPoint(x: x, y: y + 22)) }
        UIColor.lightGray.setStroke()
        path.stroke()
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


