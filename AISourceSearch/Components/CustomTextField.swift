//
//  CustomTextField.swift
//  BusterAI
//
//  Created by b on 06.11.2025.
//
import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let backgroundColor: Color
    var keyboardType: UIKeyboardType = .asciiCapable

    var body: some View {
        ZStack(alignment: .leading) {
            Image(.search)
                .padding(.leading, 24)
            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.custom("Snap ITC", size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    TextField("", text: $text)
                        .font(.custom("Snap ITC", size: 16))
                        .foregroundColor(.black)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .keyboardType(keyboardType)
                        .submitLabel(.done)
                        .textFieldStyle(.plain)
                }
                .padding(.leading, 16)
                .cornerRadius(16)
                .frame(height: 60)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(.closeButton)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 10)
                }
            }
            .cornerRadius(16)
            .padding(.trailing, 8)
            .padding(.leading, 32)
        }
        .background(backgroundColor)
        .cornerRadius(16)
    }
}
