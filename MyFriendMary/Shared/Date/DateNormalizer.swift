import Foundation

enum DateNormalizer {
    static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func addingDays(_ days: Int, to date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: startOfDay(date, calendar: calendar)) ?? startOfDay(date, calendar: calendar)
    }

    static func daysBetween(_ from: Date, _ to: Date, calendar: Calendar = .current) -> Int {
        calendar.dateComponents([.day], from: startOfDay(from, calendar: calendar), to: startOfDay(to, calendar: calendar)).day ?? 0
    }

    static func monthInterval(for date: Date, calendar: Calendar = .current) -> DateInterval {
        calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: startOfDay(date, calendar: calendar), duration: 60 * 60 * 24 * 30)
    }
}
