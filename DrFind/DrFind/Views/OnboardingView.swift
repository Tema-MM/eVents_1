import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to DrFind", description: "Discover and book appointments with doctors easily.", imageName: "wblackDr"),
        OnboardingPage(title: "Find Nearby Doctors", description: "Use our map to locate healthcare professionals in your area.", imageName: "map"),
        OnboardingPage(title: "Manage Your Bookings", description: "Keep track of your appointments and medical history.", imageName: "drBooking")
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            Button(action: {
                if currentPage == pages.count - 1 {
                    hasSeenOnboarding = true
                } else {
                    currentPage += 1
                }
            }) {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $hasSeenOnboarding) {
            RootTabView()
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.blue)
                .cornerRadius(5)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
