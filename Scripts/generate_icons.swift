import Cocoa

// MARK: - Input Source Icon Generator
// Custom design: rounded rect border with gaps on the left and right edges.
// One dot on the left (in the gap), one dot on the right (in the gap).
// Large "ক" centered inside. No bottom notch.
// Template image (alpha channel only) — macOS tints the opaque areas automatically.
// Single 44x32 pixel bitmap mapped to 22x16pt logical size (@2x).

func generateIcon() {
    let targetPath = "KolomApp/Resources/BengaliIconTemplate.tiff"

    guard let rep2x = createRepresentation(scale: 2) else {
        print("Failed to generate 2x representation.")
        return
    }
    rep2x.size = NSSize(width: 22, height: 16)
    
    guard let rep1x = createRepresentation(scale: 1) else {
        print("Failed to generate 1x representation.")
        return
    }
    rep1x.size = NSSize(width: 22, height: 16)

    let image = NSImage(size: NSSize(width: 22, height: 16))
    image.addRepresentation(rep2x)
    image.addRepresentation(rep1x)
    image.isTemplate = true

    guard let tiffData = image.tiffRepresentation else {
        print("Failed to get TIFF data.")
        return
    }

    let url = URL(fileURLWithPath: targetPath)
    try? FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )

    do {
        try tiffData.write(to: url)
        print("Successfully generated custom outline icon at: \(targetPath)")
    } catch {
        print("Failed to write icon: \(error)")
    }
}

func createRepresentation(scale: Int) -> NSBitmapImageRep? {
    let pw = 22 * scale
    let ph = 16 * scale

    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pw,
        pixelsHigh: ph,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return nil }

    NSGraphicsContext.saveGraphicsState()
    guard let ctx = NSGraphicsContext(bitmapImageRep: rep) else { return nil }
    NSGraphicsContext.current = ctx
    let cgContext = ctx.cgContext

    let w = CGFloat(pw)
    let h = CGFloat(ph)
    let s = CGFloat(scale)

    // 1. Transparent background
    cgContext.setBlendMode(.clear)
    NSColor.clear.set()
    NSRect(x: 0, y: 0, width: w, height: h).fill()
    cgContext.setBlendMode(.normal)

    NSColor.black.set()

    // 2. Draw rounded rectangle BORDER (outline only)
    let inset: CGFloat = 1.25 * s
    let borderRect = NSRect(x: inset, y: inset, width: w - 2*inset, height: h - 2*inset)
    let cornerRadius: CGFloat = 3.0 * s
    let borderPath = NSBezierPath(roundedRect: borderRect, xRadius: cornerRadius, yRadius: cornerRadius)
    borderPath.lineWidth = 1.25 * s
    borderPath.stroke()

    // 3. Clear gaps on the left and right edges for the dots
    cgContext.setBlendMode(.clear)
    let gapHeight: CGFloat = 5.0 * s
    
    // Clear left edge gap
    NSRect(
        x: borderRect.minX - 1.0 * s, 
        y: borderRect.midY - gapHeight/2.0, 
        width: 2.0 * s, 
        height: gapHeight
    ).fill()
    
    // Clear right edge gap
    NSRect(
        x: borderRect.maxX - 1.0 * s, 
        y: borderRect.midY - gapHeight/2.0, 
        width: 2.0 * s, 
        height: gapHeight
    ).fill()

    // 4. Draw one dot on the LEFT, one dot on the RIGHT (in the gaps)
    cgContext.setBlendMode(.normal)
    NSColor.black.set()
    
    let dotRadius: CGFloat = 0.9 * s
    let dotCenterY = borderRect.midY
    
    // Left dot
    let dotLeft = NSBezierPath(ovalIn: NSRect(
        x: borderRect.minX - dotRadius,
        y: dotCenterY - dotRadius,
        width: dotRadius * 2,
        height: dotRadius * 2
    ))
    dotLeft.fill()

    // Right dot
    let dotRight = NSBezierPath(ovalIn: NSRect(
        x: borderRect.maxX - dotRadius,
        y: dotCenterY - dotRadius,
        width: dotRadius * 2,
        height: dotRadius * 2
    ))
    dotRight.fill()

    // 5. Draw "ক" centered inside
    let char = "ক"
    let fontSize: CGFloat = 12.5 * s
    let font = NSFont(name: "KohinoorBangla-Medium", size: fontSize)
           ?? NSFont(name: "Kohinoor Bangla", size: fontSize)
           ?? NSFont(name: "Bangla Sangam MN", size: fontSize)
           ?? NSFont.systemFont(ofSize: fontSize, weight: .medium)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.black,
        .paragraphStyle: paragraphStyle
    ]

    let charSize = char.size(withAttributes: attrs)
    // Center text perfectly within the border
    let textY = borderRect.minY + (borderRect.height - charSize.height) / 2.0 - 0.5 * s
    let textRect = NSRect(
        x: borderRect.minX,
        y: textY,
        width: borderRect.width,
        height: charSize.height
    )
    char.draw(in: textRect, withAttributes: attrs)

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

generateIcon()
