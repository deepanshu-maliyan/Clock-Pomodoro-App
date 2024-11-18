import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            // Month header
            HStack {
                Button(action: { viewModel.moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(viewModel.monthString)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                
                Button(action: { viewModel.moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Week day headers
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.daysInMonth, id: \.self) { date in
                    Text(String(viewModel.calendar.component(.day, from: date)))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Circle()
                                .fill(backgroundColor(for: date))
                        )
                        .foregroundColor(textColor(for: date))
                        .onTapGesture {
                            viewModel.selectedDate = date
                        }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func backgroundColor(for date: Date) -> Color {
        if viewModel.isSelected(date) {
            return .blue
        } else if viewModel.isToday(date) {
            return .blue.opacity(0.3)
        }
        return .clear
    }
    
    private func textColor(for date: Date) -> Color {
        if viewModel.isSelected(date) {
            return .white
        } else if !viewModel.isCurrentMonth(date) {
            return .secondary.opacity(0.5)
        }
        return .primary
    }
}

#Preview {
    CalendarView()
} 