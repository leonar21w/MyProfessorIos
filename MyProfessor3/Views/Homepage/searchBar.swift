//
//  searchBar.swift
//  MyProfessor3
//
//  Created by Leonard on 11/17/24.
//


import SwiftUI

struct searchBar: View {
	
	@Binding var userText: String
	@Binding var toggleField: Bool
	
	@State var sampleText: String = "Ex. Math 1C"
	
	
	
	var body: some View {
		HStack {
			TextField(sampleText, text: $userText)
				.disableAutocorrection(true)
				.onSubmit {
					toggleField.toggle()
				}
			Image(systemName: "magnifyingglass")
				.foregroundStyle(Color.black)
				.onTapGesture {
					toggleField.toggle()
				}
		}
		.font(.headline)
		.padding(.horizontal)
		.padding(.vertical, 15)
		.background(RoundedRectangle(cornerRadius: 25)
			.fill(Color.gray.opacity(0.5)).shadow(radius: 10))
		.shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
		
	}
}

#Preview {
	searchBar(userText: .constant(""), toggleField: .constant(false))
}
