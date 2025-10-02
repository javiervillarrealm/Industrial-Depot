//
//  ParameterTranslator.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import Foundation

struct ParameterTranslator {
    
    // MARK: - Robot/Cobot Parameter Translations
    private static let robotParameterTranslations: [String: String] = [
        "payload": "Carga Útil",
        "reach": "Alcance",
        "repeatability": "Repetibilidad",
        "body": "Peso del Equipo",
        "weight": "Peso",
        "speed": "Velocidad",
        "accuracy": "Precisión",
        "workspace": "Espacio de Trabajo",
        "degrees": "Grados",
        "of": "de",
        "freedom": "Libertad",
        "axes": "Ejes",
        "joint": "Articulación",
        "range": "Rango",
        "motion": "Movimiento",
        "cycle": "Ciclo",
        "time": "Tiempo",
        "load": "Carga",
        "capacity": "Capacidad",
        "dimensions": "Dimensiones",
        "height": "Altura",
        "width": "Ancho",
        "depth": "Profundidad",
        "base": "Base",
        "mounting": "Montaje",
        "floor": "Piso",
        "ceiling": "Techo",
        "wall": "Pared",
        "controller": "Controlador",
        "dof": "GDL"
    ]
    
    // MARK: - Laser Parameter Translations
    private static let laserParameterTranslations: [String: String] = [
        // CSV column specific translations
        "series": "Serie",
        "fiber_core_um": "Núcleo de fibra (μm)",
        "collimation_mm": "Colimación (mm)",
        "focus_lens_mm": "Lente de enfoque (mm)",
        "material": "Material",
        "thickness_mm": "Grosor (mm)",
        "speed_m_per_min": "Velocidad (m/min)",
        "power_w": "Potencia (W)",
        "gas": "Gas",
        "pressure_bar": "Presión (bar)",
        "nozzle_diameter_mm": "Diámetro de boquilla (mm)",
        "nozzle_type": "Tipo de boquilla",
        "focus_offset_mm": "Desplazamiento de enfoque (mm)",
        "cutting_height_mm": "Altura de corte (mm)",
        "stage": "Etapa",
        "duty_percent": "Ciclo de trabajo (%)",
        "frequency_hz": "Frecuencia (Hz)",
        "nozzle_height_mm": "Altura de boquilla (mm)",
        "air_pressure_bar": "Presión de aire (bar)",
        "perforation_time_ms": "Tiempo de perforación (ms)",
        "stop_blow_ms": "Tiempo de parada de soplado (ms)",
        
        // Additional parameter variations found in CSV
        "cutting altura mm": "Altura de corte (mm)",
        "fiber core um": "Núcleo de fibra (μm)",
        "núcleo de fibra (um)": "Núcleo de fibra (μm)",
        "enfoque lens mm": "Lente de enfoque (mm)",
        "focus defset mm": "Desplazamiento de enfoque (mm)",
        "nozzle diámetro mm": "Diámetro de boquilla (mm)",
        "boquilla diameter mm": "Diámetro de boquilla (mm)",
        "boquilla type": "Tipo de boquilla",
        "potencia w": "Potencia (W)",
        "presión bar": "Presión (bar)",
        "velocidad m per min": "Velocidad (m/min)",
        "thickness mm": "Grosor (mm)",
        "collimation mm": "Colimación (mm)",
        // General laser parameter translations
        "collimation": "Colimación",
        "power": "Potencia",
        "wavelength": "Longitud de Onda",
        "beam": "Haz",
        "diameter": "Diámetro",
        "quality": "Calidad",
        "factor": "Factor",
        "cutting": "Corte",
        "speed": "Velocidad",
        "feed": "Avance",
        "rate": "Tasa",
        "assist": "Asistencia",
        "pressure": "Presión",
        "flow": "Flujo",
        "nozzle": "Boquilla",
        "standoff": "Separación",
        "pierce": "Perforación",
        "time": "Tiempo",
        "delay": "Retraso",
        "focus": "Enfoque",
        "position": "Posición",
        "offset": "Desplazamiento",
        "kerf": "Ranura",
        "width": "Ancho",
        "taper": "Conicidad",
        "angle": "Ángulo",
        "roughness": "Rugosidad",
        "surface": "Superficie",
        "finish": "Acabado"
    ]
    
    // MARK: - Material Translations
    private static let materialTranslations: [String: String] = [
        "steel": "Acero",
        "carbon steel": "Acero al Carbono",
        "carbon steel (mixed gas n2+air)": "Acero al Carbono (Gas Mixto N2+Aire)",
        "carbon steel (o2)": "Acero al Carbono (O2)",
        "stainless steel": "Acero Inoxidable",
        "aluminum": "Aluminio",
        "aluminum alloy": "Aluminio",
        "aluminium alloy": "Aluminio",
        "titanium": "Titanio",
        "copper": "Cobre",
        "brass": "Latón",
        "bronze": "Bronce",
        "mild steel": "Acero Suave",
        "galvanized steel": "Acero Galvanizado"
    ]
    
    // Complete material name translations (for specific combinations)
    private static let completeMaterialTranslations: [String: String] = [
        "mild steel": "Acero Suave",
        "carbon steel (mixed gas n2+air)": "Acero al Carbono (Gas Mixto N2+Aire)",
        "carbon steel (o2, negative focus)": "Acero al Carbono (O2, Foco Negativo)",
        "carbon steel (o2)": "Acero al Carbono (O2)",
        "carbon steel": "Acero al Carbono",
        "stainless steel": "Acero Inoxidable",
        "galvanized steel": "Acero Galvanizado",
        "coated steel": "Acero Recubierto",
        "aluminum alloy": "Aluminio",
        "aluminium alloy": "Aluminio",
        "brass": "Latón",
        "copper": "Cobre",
        "titanium": "Titanio"
    ]
    
    // MARK: - Public Methods
    static func translateParameterName(_ parameter: String) -> String {
        let normalized = parameter.lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // First check for exact matches in the translation dictionaries
        if let translation = laserParameterTranslations[normalized] {
            return translation
        }
        
        if let translation = robotParameterTranslations[normalized] {
            return translation
        }
        
        // Handle specific formatting cases first (matching Android logic)
        if normalized.contains("payload") && normalized.contains("kg") {
            return "Carga Útil (kg)"
        }
        if normalized.contains("reach") && normalized.contains("mm") {
            return "Alcance (mm)"
        }
        if normalized.contains("repeatability") && normalized.contains("mm") {
            return "Repetibilidad (mm)"
        }
        if normalized.contains("body") && normalized.contains("weight") && normalized.contains("kg") {
            return "Peso del Equipo (kg)"
        }
        if normalized.contains("collimation") && normalized.contains("mm") {
            return "Colimación (mm)"
        }
        if normalized.contains("power") && normalized.contains("kw") {
            return "Potencia (kW)"
        }
        if normalized.contains("wavelength") && normalized.contains("nm") {
            return "Longitud de Onda (nm)"
        }
        if normalized.contains("beam") && normalized.contains("diameter") && normalized.contains("mm") {
            return "Diámetro del Haz (mm)"
        }
        if normalized.contains("cutting") && normalized.contains("speed") && normalized.contains("mm/min") {
            return "Velocidad de Corte (mm/min)"
        }
        if normalized.contains("gas") && normalized.contains("pressure") && normalized.contains("bar") {
            return "Presión del Gas (bar)"
        }
        if normalized.contains("focal") && normalized.contains("length") && normalized.contains("mm") {
            return "Longitud Focal (mm)"
        }
        if normalized.contains("standoff") && normalized.contains("distance") && normalized.contains("mm") {
            return "Distancia de Separación (mm)"
        }
        if normalized.contains("pierce") && normalized.contains("time") && normalized.contains("ms") {
            return "Tiempo de Perforación (ms)"
        }
        if normalized.contains("kerf") && normalized.contains("width") && normalized.contains("mm") {
            return "Ancho de Ranura (mm)"
        }
        if normalized.contains("taper") && normalized.contains("angle") && normalized.contains("deg") {
            return "Ángulo de Conicidad (deg)"
        }
        if normalized.contains("heat") && normalized.contains("affected") && normalized.contains("zone") {
            return "Zona Afectada por el Calor"
        }
        
        // Check for partial matches
        for (key, translation) in robotParameterTranslations {
            if normalized.contains(key) {
                return normalized.replacingOccurrences(of: key, with: translation)
            }
        }
        
        for (key, translation) in laserParameterTranslations {
            if normalized.contains(key) {
                return normalized.replacingOccurrences(of: key, with: translation)
            }
        }
        
        // Return formatted original if no translation found
        return normalized.capitalized
    }
    
    static func translateMaterialName(_ material: String) -> String {
        let normalized = material.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for exact matches first in complete translations
        if let translation = completeMaterialTranslations[normalized] {
            return translation
        }
        
        // Check for exact matches in basic translations
        if let translation = materialTranslations[normalized] {
            return translation
        }
        
        // Check for partial matches
        for (key, translation) in completeMaterialTranslations {
            if normalized.contains(key) {
                return translation
            }
        }
        
        for (key, translation) in materialTranslations {
            if normalized.contains(key) {
                return translation
            }
        }
        
        // Handle special cases
        if normalized.contains("aluminum") || normalized.contains("aluminium") {
            return "Aluminio"
        }
        
        if normalized.contains("steel") && normalized.contains("carbon") {
            return "Acero al Carbono"
        }
        
        if normalized.contains("steel") && normalized.contains("stainless") {
            return "Acero Inoxidable"
        }
        
        // Return capitalized original if no translation found
        return material.capitalized
    }
    
    static func translateMaterialNameToEnglish(_ material: String) -> String {
        let normalized = material.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Reverse lookup for materials
        for (english, spanish) in materialTranslations {
            if normalized == spanish.lowercased() {
                return english
            }
        }
        
        // Handle special cases
        if normalized.contains("aluminio") {
            return "aluminum alloy"
        }
        
        if normalized.contains("acero") && normalized.contains("carbono") {
            return "carbon steel"
        }
        
        if normalized.contains("acero") && normalized.contains("inoxidable") {
            return "stainless steel"
        }
        
        // Return original if no reverse translation found
        return material
    }
}
