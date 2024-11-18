import SwiftUI

struct ClockView: View {
    @StateObject private var viewModel = ClockViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.dateString)
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(viewModel.timeString)
                .font(.system(size: 60, weight: .bold))
                .monospacedDigit()
            
            // Analog Clock Face
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                    .frame(width: 250, height: 250)
                
                // Hour markers
                ForEach(0..<12) { hour in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 4, height: hour % 3 == 0 ? 15 : 8)
                        .offset(y: -115)
                        .rotationEffect(.degrees(Double(hour) * 30))
                }
                
                // Clock hands
                ClockHands(date: viewModel.currentTime)
            }
            .padding()
            
            // Time zone picker
            Picker("Time Zone", selection: $viewModel.timeZone) {
                ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { identifier in
                    Text(identifier)
                        .tag(TimeZone(identifier: identifier) ?? TimeZone.current)
                }
            }
            .pickerStyle(.menu)
            .padding()
        }
        .padding()
    }
}

struct ClockHands: View {
    let date: Date
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let size = min(geometry.size.width, geometry.size.height)
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date) % 12
            let minute = calendar.component(.minute, from: date)
            let second = calendar.component(.second, from: date)
            
            let hourAngle = Double(hour) * 30 + Double(minute) * 0.5
            let minuteAngle = Double(minute) * 6
            let secondAngle = Double(second) * 6
            
            // Hour hand
            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + sin(hourAngle * .pi / 180) * size * 0.25,
                    y: center.y - cos(hourAngle * .pi / 180) * size * 0.25
                ))
            }
            .stroke(Color.primary, lineWidth: 4)
            
            // Minute hand
            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + sin(minuteAngle * .pi / 180) * size * 0.35,
                    y: center.y - cos(minuteAngle * .pi / 180) * size * 0.35
                ))
            }
            .stroke(Color.primary, lineWidth: 3)
            
            // Second hand
            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + sin(secondAngle * .pi / 180) * size * 0.4,
                    y: center.y - cos(secondAngle * .pi / 180) * size * 0.4
                ))
            }
            .stroke(Color.red, lineWidth: 1)
            
            // Center circle
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .position(center)
        }
    }
}

#Preview {
    ClockView()
} 