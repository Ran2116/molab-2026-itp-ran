//
//  ContentView.swift
//  Color Mosaic
//
//  Based on Instafilter by Paul Hudson (molab-itp/07-Instafilter).
//  Instead of applying a filter, this version samples the photo's colors
//  into a grid and redraws it as a mosaic, plus a palette of its main colors.
//

import PhotosUI
import SwiftUI

// One sampled color (values from 0 to 1)
struct RGB {
    var r: Double
    var g: Double
    var b: Double

    var color: Color { Color(red: r, green: g, blue: b) }

    var hex: String {
        String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// One color in the palette, with how much of the photo it covers
struct Swatch: Identifiable {
    let id = UUID()
    let color: RGB
    let share: Double
}

enum CellShape: String {
    case square = "Squares"
    case circle = "Dots"
    case tile = "Tiles"
}

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var originalImage: Image?
    @State private var smallImage: CGImage?

    @State private var grid: [[RGB]] = []
    @State private var palette: [Swatch] = []
    @State private var shareImage: Image?

    @State private var columns = 24.0
    @State private var cellShape = CellShape.square
    @State private var showingOriginal = false
    @State private var showingShapes = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                PhotosPicker(selection: $selectedItem) {
                    if showingOriginal, let originalImage {
                        originalImage
                            .resizable()
                            .scaledToFit()
                    } else if !grid.isEmpty {
                        MosaicView(grid: grid, shape: cellShape)
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)

                Spacer()

                if !palette.isEmpty {
                    PaletteView(palette: palette)
                        .padding(.bottom, 8)
                }

                Picker("View", selection: $showingOriginal) {
                    Text("Mosaic").tag(false)
                    Text("Original").tag(true)
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("Detail")
                    Slider(value: $columns, in: 8...60, step: 1)
                        .onChange(of: columns, makeMosaic)
                    Text("\(Int(columns))")
                        .monospacedDigit()
                        .frame(width: 28)
                }

                HStack {
                    Button("Change Shape") { showingShapes = true }

                    Spacer()

                    if let shareImage {
                        ShareLink(item: shareImage, preview: SharePreview("Color Mosaic", image: shareImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Color Mosaic")
            .confirmationDialog("Select a shape", isPresented: $showingShapes) {
                Button("Squares") { setShape(.square) }
                Button("Dots") { setShape(.circle) }
                Button("Tiles") { setShape(.tile) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // Loading

    @MainActor func loadImage() {
        Task {
            guard let imageData = try? await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }

            originalImage = Image(uiImage: inputImage)
            smallImage = shrink(inputImage, maxSide: 300)
            makeMosaic()
        }
    }

    // Draws the photo at a small size first. This also fixes the photo's
    // orientation, so portrait photos don't come out sideways.
    func shrink(_ image: UIImage, maxSide: CGFloat) -> CGImage? {
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let small = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return small.cgImage
    }

    //Processing

    @MainActor func makeMosaic() {
        guard let smallImage else { return }

        grid = sampleGrid(from: smallImage, columns: Int(columns))
        palette = extractPalette(from: grid, count: 6)
        renderShareImage()
    }

    @MainActor func setShape(_ shape: CellShape) {
        cellShape = shape
        renderShareImage()
    }

    // Shrinks the image down to exactly columns × rows pixels.
    // Each pixel then becomes the (roughly) average color of one cell.
    func sampleGrid(from image: CGImage, columns: Int) -> [[RGB]] {
        let rows = max(1, Int((Double(columns) * Double(image.height) / Double(image.width)).rounded()))
        var bytes = [UInt8](repeating: 0, count: columns * rows * 4)

        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: columns,
                height: rows,
                bitsPerComponent: 8,
                bytesPerRow: columns * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }

            context.interpolationQuality = .high
            context.draw(image, in: CGRect(x: 0, y: 0, width: columns, height: rows))
            return true
        }

        guard drawn else { return [] }

        return (0..<rows).map { row in
            (0..<columns).map { column in
                let i = (row * columns + column) * 4
                return RGB(r: Double(bytes[i]) / 255,
                           g: Double(bytes[i + 1]) / 255,
                           b: Double(bytes[i + 2]) / 255)
            }
        }
    }

    // Groups similar colors together (4 levels per channel = 64 groups),
    // then keeps the groups that cover the most cells.
    func extractPalette(from grid: [[RGB]], count: Int) -> [Swatch] {
        let cells = grid.flatMap { $0 }
        guard !cells.isEmpty else { return [] }

        var groups: [Int: (sum: RGB, total: Int)] = [:]

        for cell in cells {
            let key = Int(cell.r * 3.999) * 16 + Int(cell.g * 3.999) * 4 + Int(cell.b * 3.999)
            var group = groups[key] ?? (RGB(r: 0, g: 0, b: 0), 0)
            group.sum.r += cell.r
            group.sum.g += cell.g
            group.sum.b += cell.b
            group.total += 1
            groups[key] = group
        }

        return groups.values
            .sorted { first, second in first.total > second.total }
            .prefix(count)
            .map { group in
                let n = Double(group.total)
                let average = RGB(r: group.sum.r / n, g: group.sum.g / n, b: group.sum.b / n)
                return Swatch(color: average, share: n / Double(cells.count))
            }
    }

    // Turns the mosaic view into an image so it can be shared
    @MainActor func renderShareImage() {
        guard let columnCount = grid.first?.count, columnCount > 0 else { return }

        let width: CGFloat = 1080
        let height = width * CGFloat(grid.count) / CGFloat(columnCount)

        let renderer = ImageRenderer(content:
            MosaicView(grid: grid, shape: cellShape)
                .frame(width: width, height: height)
        )

        if let uiImage = renderer.uiImage {
            shareImage = Image(uiImage: uiImage)
        }
    }
}

//Mosaic

struct MosaicView: View {
    let grid: [[RGB]]
    let shape: CellShape

    var body: some View {
        let rows = grid.count
        let columns = grid.first?.count ?? 1

        Canvas { context, size in
            let cell = size.width / CGFloat(columns)

            for row in 0..<rows {
                for column in 0..<columns {
                    let rect = CGRect(x: CGFloat(column) * cell, y: CGFloat(row) * cell, width: cell, height: cell)
                    let path: Path

                    switch shape {
                    case .square:
                        path = Path(rect)
                    case .circle:
                        path = Path(ellipseIn: rect.insetBy(dx: cell * 0.08, dy: cell * 0.08))
                    case .tile:
                        path = Path(roundedRect: rect.insetBy(dx: cell * 0.1, dy: cell * 0.1), cornerRadius: cell * 0.2)
                    }

                    context.fill(path, with: .color(grid[row][column].color))
                }
            }
        }
        .aspectRatio(CGFloat(columns) / CGFloat(max(rows, 1)), contentMode: .fit)
        .background(.black)
    }
}

//Palette

struct PaletteView: View {
    let palette: [Swatch]

    var body: some View {
        let shownTotal = palette.reduce(0) { total, swatch in total + swatch.share }

        VStack(alignment: .leading, spacing: 8) {
            // Bar: each color's width matches how much of the photo it covers
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(palette) { swatch in
                        Rectangle()
                            .fill(swatch.color.color)
                            .frame(width: geometry.size.width * swatch.share / shownTotal)
                    }
                }
            }
            .frame(height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(palette) { swatch in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(swatch.color.color)
                                .frame(width: 10, height: 10)
                            Text("\(swatch.color.hex) \(Int((swatch.share * 100).rounded()))%")
                                .font(.caption2.monospaced())
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
