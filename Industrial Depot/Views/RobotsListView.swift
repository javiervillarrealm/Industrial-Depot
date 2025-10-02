//
//  RobotsListView.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import SwiftUI

struct RobotsListView: View {
    @EnvironmentObject var robotsRepository: RobotsRepository
    @State private var selectedRobot: RobotModel?
    
    var body: some View {
        VStack {
            if robotsRepository.isLoading {
                ProgressView("Cargando robots...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = robotsRepository.error {
                VStack(spacing: 16) {
                    Text("Error al cargar robots:")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.red)
                    Button("Reintentar") {
                        robotsRepository.refresh()
                    }
                }
                .padding()
            } else if robotsRepository.robots.isEmpty {
                Text("No se encontraron robots")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(robotsRepository.robots) { robot in
                    RobotRow(robot: robot) {
                        selectedRobot = robot
                    }
                }
            }
        }
        .navigationTitle("Robots Industriales")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRobot) { robot in
            RobotDetailView(robot: robot)
        }
    }
}

struct RobotRow: View {
    let robot: RobotModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Robot Image
                AsyncImage(url: Bundle.main.url(forResource: robot.imageUrl, withExtension: "png")) { image in
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
                
                // Robot Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(robot.model)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Key specifications
                    if let payload = robot.fields["Payload_kg"] {
                        Text("Carga útil (kg): \(payload)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let reach = robot.fields["Reach_mm"] {
                        Text("Alcance (mm): \(reach)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let repeatability = robot.fields["Repeatability_mm"] {
                        Text("Repetibilidad (mm): \(repeatability)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let controller = robot.fields["Controller"] {
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
        RobotsListView()
            .environmentObject(RobotsRepository())
    }
}
