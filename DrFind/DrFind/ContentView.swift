//
//  ContentView.swift
//  DrFind
//
//  Created by Makape Tema on 2025/10/03.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false  // Set to false for testing
    
    var body: some View {
        if hasSeenOnboarding {
            RootTabView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
