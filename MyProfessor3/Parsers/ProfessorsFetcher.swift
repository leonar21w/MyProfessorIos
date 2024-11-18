//
//  ProfessorsFetcher.swift
//  MyProfessor3
//
//  Created by Leonard on 11/17/24.
//
import Foundation
import SwiftSoup

@MainActor
class ProfessorsFetcher: HttpUtil, ObservableObject {

	let winterTerm2025 = ["term_code": "W2025", "term_text": "Winter 2025"]
	let summerTerm2024 = ["term_code": "M2024", "term_text": "Summer 2024"]

	func emptyInstance() -> [Professor] {
		return [
			Professor(
				name: "",
				allSchedules: ["": [""]],
				numRatings: 0,
				difficulty: 0.0,
				overallRating: 0.0,
				wouldTakeAgain: 0.0
			)
		]
	}

	func getTerms() async throws -> [[String: String]] {
		var termsFetched = try await getTermsInternal()

		if !termsFetched.contains(where: { $0 == winterTerm2025 }) {
			termsFetched.insert(winterTerm2025, at: 0)
			termsFetched.removeAll { $0["term_code"] == summerTerm2024["term_code"] }
		}

		return termsFetched
	}

	func getTermsInternal() async throws -> [[String: String]] {
		let url = "https://www.deanza.edu/schedule/"
		do {
			let soup = try await getSoup(url: url)
			let buttons = try soup.select("fieldset button.btn-term")

			return try buttons.map {
				[
					"term_code": try $0.attr("value"),
					"term_text": try $0.text()
				]
			}
		} catch {
			print("Error while fetching terms: \(error)")
			return []
		}
	}

	func getProfessorData(departmentCode: String, courseCode: String, termCode: String) async throws -> [Professor] {
		let url = "https://www.deanza.edu/schedule/listings.html?dept=\(departmentCode)&t=\(termCode)"
		do {
			let soup = try await getSoup(url: url)
			let result = try soup.select("table.table.table-schedule.table-hover.mix-container")

			guard !result.isEmpty else { return emptyInstance() }

			let rows = try result[0].select("tr")
			return buildProfessorTable(rows: rows, fullCourseCode: "\(departmentCode) \(courseCode)")
		} catch {
			print("Error fetching or processing data: \(error)")
			return emptyInstance()
		}
	}

	private func buildProfessorTable(rows: Elements, fullCourseCode: String) -> [Professor] {
		var professorTable: [String: Professor] = [:]
		let rowsArray = rows.array()

		for (index, row) in rowsArray.enumerated() {
			do {
				let columns = try row.select("td")
				guard columns.size() > 7, try columns[1].text() == fullCourseCode else { continue }

				let professorName = try columns[7].text()
				let classCode = try columns[0].text()
				let schedules = buildSchedules(rows: rows, startRowIndex: index)

				if var professor = professorTable[professorName] {
					professor.allSchedules[classCode] = schedules
				} else {
					professorTable[professorName] = Professor(
						name: convertName(professorName),
						allSchedules: [classCode: schedules],
						numRatings: 0,
						difficulty: 0.0,
						overallRating: 0.0,
						wouldTakeAgain: 0.0
					)
				}
			} catch {
				print("Error processing row: \(error)")
			}
		}

		return Array(professorTable.values)
	}

	private func buildSchedule(columns: [Element], daysCol: Int, hoursCol: Int, locationCol: Int) -> String? {
		do {
			let daysInWeek = try getDays(columns[daysCol].text())
			let hours = try columns[hoursCol].text()
			guard !hours.contains("TBA") else { return nil }
			let location = try columns[locationCol].text()
			return "\(daysInWeek) - \(hours)/\(location)"
		} catch {
			print("Error building schedule: \(error)")
			return nil
		}
	}

	func buildSchedules(rows: Elements, startRowIndex: Int) -> [String] {
		var schedules: [String] = []
		let rowsArray = rows.array()

		for i in startRowIndex..<rowsArray.count {
			do {
				let columns = try rowsArray[i].select("td")
				guard columns.size() >= 7 else { break }
				if let schedule = buildSchedule(columns: columns.array(), daysCol: 5, hoursCol: 6, locationCol: 8) {
					schedules.append(schedule)
				}
			} catch {
				print("Error parsing schedule for row \(i): \(error)")
				break
			}
		}
		return schedules
	}

	private func getDays(_ input: String) -> String {
		return input.replacingOccurrences(of: "·", with: "")
	}

	func formatSchedule(_ schedule: String?) -> String {
		return schedule ?? "No schedule/ONLINE"
	}
}

struct Professor {
	var name: String
	var allSchedules: [String: [String]] // classCode: [schedules]
	var numRatings: Int
	var difficulty: Double
	var overallRating: Double
	var wouldTakeAgain: Double
}
