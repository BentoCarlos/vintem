//
//  NewCategoryView.swift
//  vintem
//
//  Created by Bento Carlos on 20/02/26.
//

import SwiftUI
import SFSymbolsPicker

struct NewCategoryView: View {
    @EnvironmentObject private var supabase: SupabaseManager
    var paymentColor: Color
    @Binding var novaCategoriaNome: String
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false
    @State private var isSaving: Bool = false

    // Icon Picker
    @State private var icon = "star.fill"
    @State private var isPresented = false

    var isCategoryFormInvalid: Bool {
        novaCategoriaNome.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [paymentColor.opacity(0.25), paymentColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: paymentColor)

            VStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TÍTULO CATEGORIA")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(paymentColor.opacity(0.8))
                        .tracking(2)

                    TextField("Ex: Compras", text: $novaCategoriaNome)
                        .font(.system(size: 15, weight: .semibold))
                        .textFieldStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0.18), value: appeared)

                VStack(alignment: .leading, spacing: 6) {
                    Text("ÍCONE")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(paymentColor.opacity(0.8))
                        .tracking(2)

                    Button(action: { isPresented.toggle()} ) {
                        HStack {
                            Text("Selecione um ícone:")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.primary)

                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundStyle(paymentColor)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(paymentColor, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 3]))
                    )
                    .tint(paymentColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0.18), value: appeared)                .sheet(isPresented: $isPresented, content: {
                    SymbolsPicker(selection: $icon, title: "Escolha um ícone", autoDismiss: true)
                })

                HStack(spacing: 10) {
                    Button("Cancelar") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.glassProminent)
                        .tint(.secondary)

                    Button(action: { Task { await saveCategory() } }) {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView().scaleEffect(0.75).tint(.white)
                            } else {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            Text(isSaving ? "Salvando..." : "Adicionar")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.glassProminent)
                    .tint(paymentColor)
                    .disabled(isCategoryFormInvalid || isSaving)
                }
                .padding(20)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0.18), value: appeared)
            }
            .padding(20)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5).delay(0.18), value: appeared)
        }
        .frame(width: 380, height: 240)
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    func saveCategory () async {
        do {
            isSaving = true

            let newCategory = Category(
                id: nil,
                name: novaCategoriaNome,
                icon: icon != "" ? icon : nil
            )

            try await supabase.categories.insert(newCategory: newCategory)

            await supabase.refreshCategories()

            isSaving = false
            dismiss()
        } catch {
            isSaving = false
            print("Erro ao inserir nova categoria: \(error)")
        }
    }
}

#Preview {
    NewCategoryView(
        paymentColor: GetPaymentColor(type: .pix),
        novaCategoriaNome: .constant("Teste")
    )
}
