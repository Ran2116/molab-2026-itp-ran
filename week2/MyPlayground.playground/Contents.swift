import UIKit

// canvas
let dim: CGFloat = 1024
let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim, height: dim))

// color
let aqua = UIColor(red: 176/255, green: 238/255, blue: 255/255, alpha: 1)
let aqua_line = UIColor(red: 176/255, green: 238/255, blue: 180/255, alpha: 0.6)
let yellow = UIColor(red: 255/255, green: 231/255, blue: 0/255, alpha: 0.8)
let white = UIColor.white

let image = renderer.image { context in
    let ctx = context.cgContext

    // background
    let bg = CGRect(x: 0, y: 0, width: dim, height: dim)
    aqua.setFill()
    ctx.fill(bg)

//crosing road
    let numLines = 25
    let spacing = dim / 15
    let stripeW = dim / 40
    let stripeH = dim / 5

    ctx.saveGState()
    ctx.translateBy(x: dim / 2, y: dim / 2)
    ctx.rotate(by: 60 * .pi / 180)
    white.setFill()
    for i in stride(from: -(numLines / 2), through: numLines / 2, by: 1) {
        let x = CGFloat(i) * spacing
        ctx.fill(CGRect(x: x - stripeW / 2, y: -stripeH / 2, width: stripeW, height: stripeH))
    }
    ctx.restoreGState()

//crossing road_2
    let gap = dim / 2
    ctx.saveGState()
    ctx.translateBy(x: dim / 2 + dim / 8, y: dim / 2)
    ctx.rotate(by: -30 * .pi / 180)
    white.setFill()
    for i in stride(from: -(numLines / 2), through: numLines / 2, by: 1) {
        let x = CGFloat(i) * spacing
        if x < -gap / 2.5 || x > gap / 8 {
            ctx.fill(CGRect(x: x - stripeW / 2, y: -stripeH / 2, width: stripeW, height: stripeH))
        }
    }
    ctx.restoreGState()

//yellow umbrella
    let octagonCenter = CGPoint(x: dim / 2 + 50, y: dim / 2)
    let r: CGFloat = dim / 6
    let n = 8
    let angleOffset: CGFloat = -.pi / 8

    ctx.saveGState()
    ctx.translateBy(x: octagonCenter.x, y: octagonCenter.y)  //p5 translate

//bone of the umbrella
    let octagonPath = UIBezierPath()
    for i in 0..<n {
        let angle = 2 * .pi * CGFloat(i) / CGFloat(n) + angleOffset
        let x = cos(angle) * r
        let y = sin(angle) * r
        let point = CGPoint(x: x, y: y)
        i == 0 ? octagonPath.move(to: point) : octagonPath.addLine(to: point)
    }
    octagonPath.close()
    yellow.setFill()
    octagonPath.fill()

  
    aqua_line.setStroke()
    ctx.setLineWidth(dim / 200)
    for i in 0..<n {
        let angle = 2 * .pi * CGFloat(i) / CGFloat(n) + angleOffset
        let x = cos(angle) * r
        let y = sin(angle) * r
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addLine(to: CGPoint(x: x, y: y))
    }
    ctx.strokePath()

    ctx.restoreGState()
}

image
