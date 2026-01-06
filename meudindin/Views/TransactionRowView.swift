//
//  TransactionRowView.swift
//  meudindin
//
//  Created by Bento Carlos on 16/12/25.
//

import SwiftUI

struct TransactionRowView : View {
    let transaction: Transaction
    let colorPurple = Color.init(hex: "#810FCC")

    @State private var isHovered : Bool = false
    @State private var isHoveredDel : Bool = false
    @State private var isShowingAlert: Bool = false

    var onDelete: (Transaction) -> Void

    @Namespace var namespace

    var body: some View {
        GlassEffectContainer {
            HStack{
                Text("#\(transaction.id)")
                    .frame(alignment: .leading)
                    .padding()
                    .glassEffect()
                    .glassEffectUnion(id: "id-\(transaction.id)", namespace: namespace)

                Text(transaction.name)
                    .frame(alignment: .leading)
                    .padding()
                    .glassEffect()
                    .glassEffectUnion(id: "id-\(transaction.id)", namespace: namespace)

                Spacer()

                Text("R$ \(transaction.value, specifier: "%.2f")")
                    .frame(alignment: .trailing)
                    .padding()
                    .padding(.trailing, isHovered ? 40 : 0)
                    .glassEffect()
                    .glassEffectUnion(id: "id-\(transaction.id)", namespace: namespace)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .trailing) {
                Button() {
                    onDelete(transaction)
                } label: {
                    Image(systemName: "trash")
                }
                .background(isHoveredDel ? Color.red : Color.clear)
                .foregroundColor(Color.white)
                .cornerRadius(8)
                .offset(x: isHovered ? 0 : 60)
                .onHover { hoveringDel in
                    isHoveredDel = hoveringDel
                }
                .opacity(isHovered ? 1.0 : 0.0)
                .padding(.vertical, 2)
                .padding(.horizontal, 12)
                .animation(.smooth(duration: 0.15), value: isHoveredDel)
                .buttonStyle(.glass)
            }
            .animation(.smooth(duration: 0.15), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            .onTapGesture {
                isShowingAlert = true
            }
            .sheet(isPresented: $isShowingAlert) {
                TransactionDetailView(transaction: transaction)
            }
        }
    }
}
