import Foundation

enum DateHelpers {
    static func scheduledDate(dob: Date, weeks: Int) -> Date {
        let daysToAdd = weeks * 7
        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: dob.startOfDay) ?? dob
    }

    static func formatDate(_ date: Date) -> String {
        Formatters.longDate.string(from: date)
    }

    static func shortDate(_ date: Date) -> String {
        Formatters.shortDate.string(from: date)
    }

    static func relativeDays(to target: Date) -> String {
        let now = Date().startOfDay
        let t = target.startOfDay
        let days = Calendar.current.dateComponents([.day], from: now, to: t).day ?? 0
        if days == 0 { return NSLocalizedString("Today", comment: "") }
        if days > 0 { return String(format: NSLocalizedString("In %d days", comment: ""), days) }
        return String(format: NSLocalizedString("%d days ago", comment: ""), abs(days))
    }

    static func milestoneLabel(weeks: Int) -> String {
        if weeks == 0 { return NSLocalizedString("Birth", comment: "") }
        return String(format: NSLocalizedString("%d Weeks", comment: ""), weeks)
    }

    static func relativeDOB(_ dob: Date) -> String {
        let years = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
        return String(format: NSLocalizedString("Age %d years", comment: ""), years)
    }
}

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}

enum Formatters {
    static let longDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    static let shortDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()

    static func grams(_ grams: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        let s = nf.string(from: NSNumber(value: grams)) ?? "\(grams)"
        return "\(s) g"
    }
}


