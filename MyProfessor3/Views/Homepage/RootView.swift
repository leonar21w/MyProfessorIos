//
//  RootView.swift
//  MyProfessor3
//
//  Created by Leonard on 11/17/24.
//

import SwiftUI

struct RootView: View {
	@State private var isLoading = false
	@State private var pressed = false
	@State var userText = ""
	
	@State var quarter = ""
	@State var earlyQuarter = "Fall 2024"
	@State var lateQuarter = "Winter 2025"
	
	@State private var showAlert = false
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
					VStack {
						MyProfessorLogo()
							.padding(.top, 20)
						searchSection
						quarterButtons
					}
					HStack {
						VStack(alignment: .leading) {
							Text("Recent searches")
								.font(.headline)
								.fontWeight(.bold)
								.foregroundStyle(Color.black)
							
							RecentSearchCells(searchHistory: "Math 1A - 2024 Fall")
							RecentSearchCells(searchHistory: "Math 1B - 2025 Winter")
						}
						.padding()
						Spacer()
					}
					Spacer()
				}
			}
			.navigationDestination(isPresented: $pressed) {
				if let (departmentCode, courseCode) = splitStringByFirstInteger(input: userText) {
					ResultsView(departmentCode: departmentCode, courseCode: courseCode, termCode: quarter)
				}
			}
		}
	}
	
	private var searchSection: some View {
		VStack(alignment: .center) {
			Text("Find your professor")
				.font(.subheadline)
				.fontWeight(.bold)
			SearchBar(userText: $userText, toggleField: $pressed)
				.padding(.horizontal, 50)
				.padding(.top, 50)
		}
	}
	
	private var quarterButtons: some View {
		HStack {
			QuarterButton(title: earlyQuarter, isSelected: quarter == "F2024") {
				quarter = "F2024"
			}
			.padding()
			
			QuarterButton(title: lateQuarter, isSelected: quarter == "W2025") {
				quarter = "W2025"
			}
			.padding()
		}
	}
	
	func splitStringByFirstInteger(input: String) -> (String, String)? {
		let trimmedInput = input.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
		if let range = trimmedInput.range(of: "\\d", options: .regularExpression) {
			let beforeInteger = String(trimmedInput[..<range.lowerBound])
			let afterInteger = String(trimmedInput[range.lowerBound...])
			return (beforeInteger.uppercased(), afterInteger.uppercased())
		}
		return nil
	}
}

struct QuarterButton: View {
	let title: String
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(isSelected ? Color.white : Color.black)
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 25)
						.fill(isSelected ? Color.blue : Color.gray.opacity(0.5))
				)
		}
	}
}

#Preview {
	RootView()
}
