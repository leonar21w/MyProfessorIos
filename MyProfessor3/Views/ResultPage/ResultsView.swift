//
//  ResultsView.swift
//  MyProfessor3
//
//  Created by Leonard on 11/17/24.
//

import SwiftUI

struct ResultsView: View {

	@State var showLoading: Bool = true
	
	//parameters
	@State var departmentCode: String
	@State var courseCode: String
	@State var termCode: String
	
	@StateObject var dataVM = DataTunnelVM()
	@StateObject var getProfessors = ProfessorsFetcher()
	@State var professorData: [Professor] = []
	
	
	var body: some View {
		ZStack{
			VStack{
				HStack {
					MyProfessorLogo()
						.padding()
					classDetails
						.padding()
				}
				
				if !showLoading {
					ListProfessors
				} else {
					ProgressView()
				}
				
				
				Spacer()
				
			}
		}.onAppear {
			Task {
				professorData = try await getProfessors.getProfessorData(
					departmentCode: departmentCode, courseCode: courseCode, termCode: termCode)
				showLoading.toggle()
				try await dataVM.searchProfessorAndGetRatings(professors: professorData, departmentCode: departmentCode, courseCode: courseCode, termCode: termCode)
			}
		}
	}
	
	private var ListProfessors: some View {
		ScrollView {
			VStack(alignment: .leading){
				ForEach(dataVM.professorData, id: \.name) { professor in
					VStack(alignment: .leading){
						HStack{
							Text(professor.name)
								.font(.system(size: 20))
								.fontWeight(.semibold)
								.foregroundStyle(Color.black)
							Text("\(professor.numRatings)")
								.font(.footnote)
								.fontWeight(.light)
								.foregroundStyle(Color.gray)
							Spacer()
						}
						
						HStack{
							HStack{
								Circle()
									.foregroundStyle(Color.customGreen)
									.frame(width: 16, height: 16)
								Text("Difficulty: \(professor.difficulty, specifier: "%.1f")")
									.font(.footnote)
									.fontWeight(.medium)
							}
							HStack{
								Circle()
									.foregroundStyle(Color(red: 1, green: 0.74, blue: 0.35))
									.frame(width: 16, height: 16)
								Text("Rating: \(professor.overallRating, specifier: "%.1f")")
									.font(.footnote)
									.fontWeight(.medium)
							}
							HStack {
								Circle()
									.foregroundStyle(Color(red: 0.85, green: 0.38, blue: 0.38))
									.frame(width: 16, height: 16)
								
								Text("Recommend: \(professor.wouldTakeAgain, specifier: "%.0f")%")
									.font(.footnote)
									.fontWeight(.medium)
							}
						}.padding(5)
							.background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
						VStack(alignment: .leading) {
							ForEach(Array(professor.allSchedules.keys), id: \.self) { CRN in
								
								VStack(alignment: .leading) {
									//Validate theres a schedule for that crn
									if let schedule = professor.allSchedules[CRN] {
										
										VStack(alignment: .leading){
											
											Text(CRN)
												.font(.footnote)
												.fontWeight(.light)
												.padding(2)
												.background(RoundedRectangle(cornerRadius: 20).fill(Color.orange.opacity(0.5)))
										}
										VStack(alignment: .leading) {
											ForEach(schedule, id: \.self) { time in
												
												Text(time)
													.font(.footnote)
													.padding(5)
											}
										}.background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.2)))
									}
								}
							}
						}.padding(5).background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1)))
					}
				}
				
			}
		}.padding()
	}
	
	private var classDetails: some View {
		VStack(spacing: 0) {
			Text("\(departmentCode)")
				.foregroundStyle(Color.black)
			Text(termCode)
				.foregroundStyle(Color.gray.opacity(0.5))
		}
		.font(.system(size: 32, weight: .semibold, design: .default))
	}
}

#Preview {
	ResultsView(departmentCode: "MATH", courseCode: "1C", termCode: "W2025")
}
