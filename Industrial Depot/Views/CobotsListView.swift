//
//  CobotsListView.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import SwiftUI

struct CobotsListView: View {
    @EnvironmentObject var cobotsRepository: CobotsRepository
    @State private var selectedCobot: RobotModel?
    
    var body: some View {
        VStack {
            if cobotsRepository.isLoading {
                ProgressView("Cargando cobots...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = cobotsRepository.error {
                VStack(spacing: 16) {
                    Text("Error al cargar cobots:")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.red)
                    Button("Reintentar") {
                        cobotsRepository.refresh()
                    }
                }
                .padding()
            } else if cobotsRepository.cobots.isEmpty {
                Text("No se encontraron cobots")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(cobotsRepository.cobots) { cobot in
                    CobotRow(cobot: cobot) {
                        selectedCobot = cobot
                    }
                }
            }
        }
        .navigationTitle("Cobots")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedCobot) { cobot in
            RobotDetailView(robot: cobot)
        }
    }
}

struct CobotRow: View {
    let cobot: RobotModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Cobot Image
                AsyncImage(url: Bundle.main.url(forResource: cobot.imageUrl, withExtension: "png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
                
                // Cobot Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(cobot.model)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Key specifications
                    if let payload = cobot.fields["Payload_kg"] {
                        Text("Carga útil (kg): \(payload)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let reach = cobot.fields["Reach_mm"] {
                        Text("Alcance (mm): \(reach)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let repeatability = cobot.fields["Repeatability_mm"] {
                        Text("Repetibilidad (mm): \(repeatability)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let controller = cobot.fields["Controller"] {
                        Text("Controlador: \(controller)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        CobotsListView()
            .environmentObject(CobotsRepository())
    }
}
