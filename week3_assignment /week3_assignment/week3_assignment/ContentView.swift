//
//  ContentView.swift
//  week3_assignment
//
//  Created by Ran Xu on 9/23/26.
//


import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 40) {
        Spacer()

        // Logo
          Image(systemName: "square")
              .resizable()
              .aspectRatio(contentMode:.fit)
              .frame(width: 100, height: 100)
          
        Text("Random Grid")
          .font(.largeTitle)
          .bold()

        Spacer()

        // Start button
        NavigationLink {
          GridView()
        } label: {
          Text("Start Randomize")
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.bottom, 60)
      }
    }
  }
}


struct GridView: View {

  // random color
  let colorPool: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink, .cyan, .mint, .indigo]


  @State private var squareColors: [Color] = GridView.randomColors()

  // grid size
  let gridSize = 4

  var body: some View {
    VStack {
      Canvas { context, size in
        let cols = gridSize
        let rows = gridSize

        // size of cell
        let cellWidth = size.width / CGFloat(cols)
        let cellHeight = size.height / CGFloat(rows)

        for row in 0..<rows {
          for col in 0..<cols {
            let index = row * cols + col

            let rect = CGRect(
              x: CGFloat(col) * cellWidth,
              y: CGFloat(row) * cellHeight,
              width: cellWidth,
              height: cellHeight
            )

            let squarePath = Rectangle().path(in: rect)

            // Fill the square
            context.fill(squarePath, with: .color(squareColors[index]))

          }
        }
      }
      .aspectRatio(1, contentMode: .fit) // keep the grid square-shaped
      .padding()

      Button(action: {
        squareColors = GridView.randomColors()
      }) {
        Text("Randomize")
          .font(.headline)
          .padding(.horizontal, 24)
          .padding(.vertical, 10)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
      .padding(.bottom)
    }
  }

  // random color
  static func randomColors() -> [Color] {
    let pool: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink, .cyan, .mint, .indigo]
    return (0..<16).map { _ in pool.randomElement()! }
  }
}

#Preview {
  ContentView()
}
