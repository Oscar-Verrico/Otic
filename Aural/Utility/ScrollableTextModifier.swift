//
//  ScrollableTextModifier.swift
//  Aural
//
//  Created by Oscar Verrico on 12/9/24.
//


import SwiftUI

extension View {
    func scrollableText() -> some View {
        self.modifier(ScrollableTextModifier())
    }
}

struct ScrollableTextModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    @State private var isScrolling: Bool = false

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(x: offset)
                .onAppear {
                    if geometry.size.width < geometry.size.width {
                        startScrolling(width: geometry.size.width)
                    }
                }
        }
    }

    private func startScrolling(width: CGFloat) {
        isScrolling = true
        withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
            offset = -width
        }
    }
}
