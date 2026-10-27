import SwiftUI

/// A symbol falling back to a bundled asset of the same name, since not all are system.
struct SymbolImage: View {
    let name: String
    let size: CGFloat
    var weight: Font.Weight = .regular
    var monochrome = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if NSImage(systemSymbolName: name, accessibilityDescription: nil) == nil {
            if monochrome {
                Image(name)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
        } else {
            Image(systemName: SystemSymbolName.resolve(name, isDark: colorScheme == .dark))
                .font(.system(size: size, weight: weight))
                .symbolRenderingMode(monochrome ? .monochrome : .hierarchical)
        }
    }
}
