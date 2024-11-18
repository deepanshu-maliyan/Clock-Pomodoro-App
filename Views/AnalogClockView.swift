import UIKit

class AnalogClockView: UIView {
    
    // MARK: - Properties
    private let hourHand = CAShapeLayer()
    private let minuteHand = CAShapeLayer()
    private let secondHand = CAShapeLayer()
    private let centerPoint = CAShapeLayer()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupClockFace()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupClockFace()
    }
    
    // MARK: - Setup
    private func setupClockFace() {
        // Clock face
        let clockFace = CAShapeLayer()
        clockFace.fillColor = UIColor.clear.cgColor
        clockFace.strokeColor = UIColor.label.cgColor
        clockFace.lineWidth = 2
        layer.addSublayer(clockFace)
        
        // Hour markers
        let markerLayer = CAShapeLayer()
        markerLayer.strokeColor = UIColor.label.cgColor
        layer.addSublayer(markerLayer)
        
        // Clock hands
        [hourHand, minuteHand, secondHand].forEach {
            $0.strokeColor = UIColor.label.cgColor
            $0.lineWidth = 2
            $0.lineCap = .round
            layer.addSublayer($0)
        }
        
        secondHand.strokeColor = UIColor.systemRed.cgColor
        
        // Center point
        centerPoint.fillColor = UIColor.systemRed.cgColor
        layer.addSublayer(centerPoint)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 4
        
        // Draw clock face
        let clockPath = UIBezierPath(arcCenter: center,
                                   radius: radius,
                                   startAngle: 0,
                                   endAngle: 2 * .pi,
                                   clockwise: true)
        
        let clockFace = layer.sublayers?.first as? CAShapeLayer
        clockFace?.path = clockPath.cgPath
        
        // Draw hour markers
        let markerPath = UIBezierPath()
        for i in 0..<12 {
            let angle = CGFloat(i) * .pi / 6
            let markerLength: CGFloat = i % 3 == 0 ? 15 : 10
            
            let startPoint = CGPoint(
                x: center.x + (radius - markerLength) * sin(angle),
                y: center.y - (radius - markerLength) * cos(angle)
            )
            let endPoint = CGPoint(
                x: center.x + radius * sin(angle),
                y: center.y - radius * cos(angle)
            )
            
            markerPath.move(to: startPoint)
            markerPath.addLine(to: endPoint)
        }
        
        let markerLayer = layer.sublayers?[1] as? CAShapeLayer
        markerLayer?.path = markerPath.cgPath
        
        // Update center point
        let centerDot = UIBezierPath(arcCenter: center,
                                   radius: 4,
                                   startAngle: 0,
                                   endAngle: 2 * .pi,
                                   clockwise: true)
        centerPoint.path = centerDot.cgPath
    }
    
    // MARK: - Update Time
    func updateTime(date: Date, timeZone: TimeZone = .current) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .second], from: date)
        components.timeZone = timeZone
        
        guard let hour = components.hour,
              let minute = components.minute,
              let second = components.second else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 4
        
        // Hour hand
        let hourAngle = CGFloat(hour % 12 + minute / 60) * .pi / 6
        let hourHandLength = radius * 0.5
        let hourHandEnd = CGPoint(
            x: center.x + hourHandLength * sin(hourAngle),
            y: center.y - hourHandLength * cos(hourAngle)
        )
        
        let hourPath = UIBezierPath()
        hourPath.move(to: center)
        hourPath.addLine(to: hourHandEnd)
        hourHand.path = hourPath.cgPath
        
        // Minute hand
        let minuteAngle = CGFloat(minute + second / 60) * .pi / 30
        let minuteHandLength = radius * 0.7
        let minuteHandEnd = CGPoint(
            x: center.x + minuteHandLength * sin(minuteAngle),
            y: center.y - minuteHandLength * cos(minuteAngle)
        )
        
        let minutePath = UIBezierPath()
        minutePath.move(to: center)
        minutePath.addLine(to: minuteHandEnd)
        minuteHand.path = minutePath.cgPath
        
        // Second hand
        let secondAngle = CGFloat(second) * .pi / 30
        let secondHandLength = radius * 0.9
        let secondHandEnd = CGPoint(
            x: center.x + secondHandLength * sin(secondAngle),
            y: center.y - secondHandLength * cos(secondAngle)
        )
        
        let secondPath = UIBezierPath()
        secondPath.move(to: center)
        secondPath.addLine(to: secondHandEnd)
        secondHand.path = secondPath.cgPath
    }
} 