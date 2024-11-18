import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ClockView()
                .tabItem {
                    Label("Clock", systemImage: "clock")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            PomodoroView()
                .tabItem {
                    Label("Pomodoro", systemImage: "timer")
                }
                .tag(2)
            
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer.circle")
                }
                .tag(3)
            
            StopwatchView()
                .tabItem {
                    Label("Stopwatch", systemImage: "stopwatch")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
} 