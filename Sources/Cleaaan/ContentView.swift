import SwiftUI
import CleaaanCore

// MARK: - Root view

struct ContentView: View {
    @State private var desktopSelected  = true
    @State private var downloadsSelected = false
    @AppStorage("selectedTheme") private var theme: ThemeType = .light
    @State private var feedbackText: String? = nil
    @State private var showCheckmark = false
    @State private var isCleaning    = false

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LogoView(theme: theme)

                Spacer().frame(height: 28)

                HStack(spacing: 12) {
                    ToggleButton(title: "Desktop",   isSelected: $desktopSelected,   theme: theme)
                    ToggleButton(title: "Downloads", isSelected: $downloadsSelected, theme: theme)
                }

                Spacer().frame(height: 16)

                PulisciButton(
                    isEnabled:     desktopSelected || downloadsSelected,
                    showCheckmark: showCheckmark,
                    theme:         theme,
                    action:        pulisci
                )

                // Reserve space so layout doesn't jump when text appears
                Group {
                    if let text = feedbackText {
                        Text(text)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.feedbackColor)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .frame(height: 24)

                Spacer()

                ThemeSwitcher(currentTheme: $theme)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 40)
            .padding(.top, 28)
        }
        .frame(width: 460, height: 340)
    }

    private func pulisci() {
        guard !isCleaning else { return }
        isCleaning = true

        Task {
            let home    = FileManager.default.homeDirectoryForCurrentUser
            let destBase = home.appendingPathComponent("Desktop/\(FileOrganizer.destinationName)")
            var sources: [URL] = []
            if desktopSelected  { sources.append(home.appendingPathComponent("Desktop")) }
            if downloadsSelected { sources.append(home.appendingPathComponent("Downloads")) }

            let count = FileOrganizer.clean(sources: sources, destinationBase: destBase)

            withAnimation(.spring(response: 0.3)) {
                showCheckmark = true
                feedbackText  = count == 1 ? "1 file spostato" : "\(count) file spostati"
            }

            try? await Task.sleep(for: .seconds(2.5))

            withAnimation(.easeInOut(duration: 0.4)) {
                showCheckmark = false
                feedbackText  = nil
            }
            isCleaning = false
        }
    }
}

// MARK: - Logo

private struct LogoView: View {
    let theme: ThemeType

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("Cleaaan")
                .font(Font.custom("GenericG20FRClassicDEMO", size: 56))
                .foregroundStyle(theme.logoColor)
                .padding(.trailing, 26)

            // Sparkle cluster top-right (3 stars, varying sizes)
            HStack(alignment: .top, spacing: 1) {
                VStack(spacing: 1) {
                    Spacer().frame(height: 5)
                    Image(systemName: "sparkle").font(.system(size: 9,  weight: .medium))
                }
                VStack(spacing: 2) {
                    Image(systemName: "sparkle").font(.system(size: 15, weight: .medium))
                    Image(systemName: "sparkle").font(.system(size: 11, weight: .medium))
                }
            }
            .foregroundStyle(theme.logoColor)
            .offset(x: 2, y: -5)
        }
    }
}

// MARK: - Source toggle button

private struct ToggleButton: View {
    let title: String
    @Binding var isSelected: Bool
    let theme: ThemeType

    var body: some View {
        Button { isSelected.toggle() } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? theme.toggleActiveText : theme.toggleInactiveText)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isSelected ? theme.toggleActiveBackground : theme.toggleInactiveBackground)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Pulisci button

private struct PulisciButton: View {
    let isEnabled:     Bool
    let showCheckmark: Bool
    let theme:         ThemeType
    let action:        () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if showCheckmark {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    HStack(spacing: 6) {
                        Text("Pulisci")
                            .font(.system(size: 17, weight: .bold))
                        Image(systemName: "sparkle")
                            .font(.system(size: 11))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(theme.pulisciText)
            .frame(width: 280, height: 52)
            .background(
                Capsule().fill(theme.pulisciBackground.opacity(isEnabled ? 1.0 : 0.35))
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .scaleEffect(showCheckmark ? 1.04 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: showCheckmark)
    }
}

// MARK: - Theme switcher (3 colored dots)

private struct ThemeSwitcher: View {
    @Binding var currentTheme: ThemeType

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ThemeType.allCases, id: \.self) { t in
                Circle()
                    .fill(t.swatchColor)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                currentTheme == t ? Color.white : Color.clear,
                                lineWidth: 2
                            )
                            .padding(-2)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { currentTheme = t }
                    }
            }
        }
    }
}
