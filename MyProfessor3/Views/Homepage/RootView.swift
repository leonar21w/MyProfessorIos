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
							
							RecentSearchCells(searchHistory: "Math 1A -2024 Fall")
							RecentSearchCells(searchHistory: "Math 1A -2024 Fall")
						}
						.padding()
						Spacer()
					}
					Spacer()
				}
			}
			.navigationDestination(isPresented: $pressed) {
				ResultsView(departmentCode: "MATH", courseCode: "1A", termCode: "W2025")
			}
		}
	}
	
	private var searchSection: some View {
		VStack(alignment: .center) {
			Text("Find your professor")
				.font(.subheadline)
				.fontWeight(.bold)
			searchBar(userText: $userText, toggleField: $pressed)
				.padding(.horizontal, 50)
				.padding(.top, 50)
		}
	}
	
	private var quarterButtons: some View {
		HStack {
			earlyQuarterButton
				.padding()
			lateQuarterButton
				.padding()
		}
	}
	
	private var earlyQuarterButton: some View {
		Button(action: helperEQuarter) {
			Text(earlyQuarter)
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(Color.black)
				.padding()
				.background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.5)))
		}
	}
	private var lateQuarterButton: some View {
		Button(action: helperLQuarter) {
			Text(lateQuarter)
				.font(.subheadline)
				.fontWeight(.medium)
				.foregroundStyle(Color.black)
				.padding()
				.background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.5)))
		}
	}
	
	private func helperEQuarter() {
		quarter = "F2024"
	}
	private func helperLQuarter() {
		quarter = "W2025"
	}

	
}

#Preview {
	RootView()
}
