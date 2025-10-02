//
//  WelcomeView.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var robotsRepository = RobotsRepository()
    @StateObject private var cobotsRepository = CobotsRepository()
    @StateObject private var laserRepository = LaserDataRepository()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Welcome Text
                VStack(spacing: 16) {
                Text("Bienvenido a Industrial Depot")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Mercado de Maquinaria Industrial")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Categories
                VStack(spacing: 16) {
                    Text("Categorías")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: CobotsListView()) {
                            CategoryCardView(title: "Cobots", imageName: "GCR3-618")
                        }
                        
                        NavigationLink(destination: RobotsListView()) {
                            CategoryCardView(title: "Robots Industriales", imageName: "SR25A-20:1.80")
                        }
                        
                        NavigationLink(destination: LaserCalculatorView()) {
                            CategoryCardView(title: "Láser", imageName: "laser_machine")
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .environmentObject(robotsRepository)
        .environmentObject(cobotsRepository)
        .environmentObject(laserRepository)
    }
}

struct CategoryCardView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        HStack(spacing: 16) {
                // Image
                AsyncImage(url: Bundle.main.url(forResource: imageName, withExtension: imageName == "laser_machine" ? "jpg" : "png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    WelcomeView()
}
