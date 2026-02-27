import SwiftUI

struct MonthGridView: View {
    let month: Date
    let marks: [CalendarDayMark]

    private let calendar = Calendar.current
    private let weekdaySymbols = ["L", "M", "X", "J", "V", "S", "D"]

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear
                        .frame(height: 42)
                }

                ForEach(daysInMonth, id: \.self) { day in
                    dayCell(for: day)
                }
            }
        }
    }

    private var daysInMonth: [Date] {
        let interval = DateNormalizer.monthInterval(for: month)
        let start = DateNormalizer.startOfDay(interval.start)
        let count = max(0, DateNormalizer.daysBetween(start, interval.end))
        return (0..<count).map { DateNormalizer.addingDays($0, to: start) }
    }

    private var leadingEmptyDays: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay)
        // Ajuste a semana iniciando en lunes.
        return (weekday + 5) % 7
    }

    private func dayCell(for day: Date) -> some View {
        let mark = markForDay(day)

        return VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: day))")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: 2) {
                marker(isVisible: mark?.hasPeriod == true, color: AppColors.period)
                marker(isVisible: mark?.isPredictedFertile == true, color: AppColors.fertile)
                marker(isVisible: mark?.hasSymptoms == true, color: AppColors.symptom)
                marker(isVisible: mark?.hasSexEntry == true, color: AppColors.encounter)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 42)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }

    @ViewBuilder
    private func marker(isVisible: Bool, color: Color) -> some View {
        Circle()
            .fill(isVisible ? color : .clear)
            .frame(width: 5, height: 5)
    }

    private func markForDay(_ day: Date) -> CalendarDayMark? {
        let key = DayKeyFormatter.string(from: day)
        return marks.first { DayKeyFormatter.string(from: $0.day) == key }
    }
}
