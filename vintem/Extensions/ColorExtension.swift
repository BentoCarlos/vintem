//
//  ColorExtension.swift
//  meudindin
//
//  Created by Bento Carlos on 09/12/25.
//

import SwiftUI

extension Color {
    /// Inicializa uma cor SwiftUI a partir de um valor hexadecimal (ex: #810FCC).
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexInt: UInt64 = 0

        // Tenta escanear o valor hexadecimal e atribui a hexInt
        guard scanner.scanHexInt64(&hexInt) else {
            // Se falhar (código inválido), retorna preto e sai
            self.init(.black)
            return
        }

        let r, g, b: Double

        // Extrai os componentes de cor, dependendo do comprimento do código hex
        let length = hex.count - (hex.hasPrefix("#") ? 1 : 0)

        if length == 6 { // Ex: #RRGGBB
            r = Double((hexInt & 0xFF0000) >> 16) / 255.0
            g = Double((hexInt & 0x00FF00) >> 8) / 255.0
            b = Double(hexInt & 0x0000FF) / 255.0
        } else if length == 8 { // Ex: #AARRGGBB (incluindo Alpha)
            let a = Double((hexInt & 0xFF000000) >> 24) / 255.0
            r = Double((hexInt & 0x00FF0000) >> 16) / 255.0
            g = Double((hexInt & 0x0000FF00) >> 8) / 255.0
            b = Double(hexInt & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, opacity: a)
            return
        } else {
            // Caso o código hexadecimal seja inválido, usa a cor preta
            self.init(.black)
            return
        }

        self.init(red: r, green: g, blue: b)
    }
}
