//
//  ArtworkList.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import ComposableArchitecturePattern
import SwiftUI

enum ArtworkList {
	enum ListActions {
		case showRecords(forPage: Int)
		case refresh
	}
	
	struct RecordGroup {
		let page: Int
		let records: [ObjectRecord]
	}
	
	actor DataSource: ArtworkListDataProvider {
		static let productionEnvironment: ServerEnvironment = .production(url: "https://api.harvardartmuseums.org")
		static let availableEnvironments: [ServerEnvironment] = [
			productionEnvironment
		]
		static var objectAPIQueries: [URLQueryItem] = [
			.init(name: "fields", value: "*"),
			.init(name: "sort", value: "random"),
			.init(name: "size", value: "25"),
			.init(name: "q", value: "*:*"),
			.init(name: "hasimage", value: "1"),
			.init(name: "apikey", value: ProcessInfo.processInfo.environment["API_KEY"]),
		]
		static let objectAPI = ObjectAPI(environment: productionEnvironment, path: "object", headers: nil, queries: objectAPIQueries, supportedHTTPMethods: [.GET], supportedReturnObjects: nil, timeoutInterval: 1000)
		
		lazy var server = ArtServer<ObjectAPI>(environments: Self.availableEnvironments, currentEnvironment: Self.productionEnvironment, supportedAPIs: [Self.objectAPI])
		
		func fetchMuseumArt(forPage: Int) async throws -> ObjectAPIResponse {
			let additionalQueries: [URLQueryItem]? = {
				var additionalQueries = [URLQueryItem]()
				let pageQuery = URLQueryItem(name: "page", value: forPage.description)
				additionalQueries.append(pageQuery)
				return additionalQueries
			}()
			let response: ObjectAPIResponse = try await self.server.get(Self.objectAPI, queries: additionalQueries, dateDecodingStrategy: .deferredToDate)
			return response
		}
	}
	
	@Observable
	class ViewModel {
		var artwork = [ObjectRecord]()
		var currentPage = 0
		var totalPages = 0
		var recordGroups = [RecordGroup]()
		
		var canGoToNextPage: Bool {
			guard !self.recordGroups.isEmpty else {
				return false
			}
			
			return self.currentPage < self.totalPages
		}
		
		var canGoToPreviousPage: Bool {
			guard !self.recordGroups.isEmpty else {
				return false
			}
			
			return self.currentPage > 1
		}
	}
	
	struct ContentView: View {
		typealias Actions = ListActions
		enum Design {
			static let minimumListWidth = CGFloat(250)
			static let idealListWidth = CGFloat(400)
			static let minimumViewHeight = CGFloat(250)
			static let idealViewHeight = CGFloat(450)
			static let minimumSidebarWidth = CGFloat(150)
			static let idealSidebarWidth = CGFloat(300)
		}
		
		enum ViewStyle: String, CaseIterable {
			case list
			case sidebar
			
			var imageName: String {
				switch self {
					case .list:
						return "list.bullet"
					case .sidebar:
						return "sidebar.left"
				}
			}
		}
		
		var viewModel: ViewModel
		let perform: OutputHandler<Actions>
		
		@State private var selection: ObjectRecord?
		@State private var showSelection = false
		@SceneStorage("ViewStyle") var viewStyle: ViewStyle = .sidebar
		
		private var currentGroup: RecordGroup? {
			return self.viewModel.recordGroups.lazy.first(where: { $0.page == self.viewModel.currentPage })
		}
		
		private var currentGroupRecords: [ObjectRecord] {
			return self.currentGroup?.records ?? []
		}
		
		private var navigationTitle: LocalizedStringKey {
			guard !self.viewModel.recordGroups.isEmpty else {
				return "Harvard Artwork Collection"
			}
			
			return "Harvard Artwork Collection: Page \(self.viewModel.currentPage)"
		}
		
		@State private var searchText = ""
		private var filteredRecords: [ObjectRecord] {
			guard !self.searchText.isEmpty else {
				return self.currentGroupRecords
			}
			
			return self.currentGroupRecords.filter({
				$0.title.localizedCaseInsensitiveContains(self.searchText) ||
				$0.dated?.localizedCaseInsensitiveContains(self.searchText) ?? false ||
				$0.classification?.localizedCaseInsensitiveContains(self.searchText) ?? false ||
				$0.creditline?.localizedCaseInsensitiveContains(self.searchText) ?? false ||
				$0.objectnumber?.localizedCaseInsensitiveContains(self.searchText) ?? false ||
				$0.people?.contains(where: { person in person.displayname.localizedCaseInsensitiveContains(self.searchText) }) ?? false
			})
		}
		
		var body: some View {
			self.baseView
				.frame(minHeight: Design.minimumViewHeight, idealHeight: Design.idealViewHeight)
				.searchable(text: self.$searchText)
				.overlay {
					if self.currentGroup == nil {
						ProgressView()
					}
				}
				.refreshable {
					do {
						try await self.perform(.refresh)
					} catch {
						print("***** error: \(error)")
					}
				}
				.navigationTitle(self.navigationTitle)
				.onKeyPress(keys: [.return], action: { press in
					self.showSelection = true
					return .handled
				})
				.toolbar {
					#if os(iOS)
					ToolbarItem(placement: .topBarLeading) {
						if !self.viewModel.recordGroups.isEmpty {
							self._previousPageButton
						}
					}
					
					ToolbarItem(placement: .topBarTrailing) {
						if !self.viewModel.recordGroups.isEmpty {
							self._nextPageButton
						}
					}
					#else
					ToolbarItemGroup(placement: .primaryAction) {
						if !self.viewModel.recordGroups.isEmpty {
							self._previousPageButton
							
							self._nextPageButton
						}
					}
					#endif
					ToolbarItem(placement: .automatic) {
						Picker(selection: self.$viewStyle) {
							ForEach(ViewStyle.allCases, id: \.self) { style in
								Image(systemName: style.imageName)
							}
						} label: {
							Image(systemName: self.viewStyle.imageName)
						}
						.help("The layout of the view.")
					}
				}
				.sheet(isPresented: self.$showSelection, content: {
					if let selection {
						ArtworkDetail.RecordDetail(record: selection, letDismiss: true)
					}
				})
		}
		
		@ViewBuilder
		private var baseView: some View {
			switch self.viewStyle {
				case .list:
					self.list
				case .sidebar:
					self.splitView
			}
		}
		
		private var list: some View {
			List(self.filteredRecords, id: \.self, selection: self.$selection) { record in
				RecordRow(record: record)
			}
			.frame(minWidth: Design.minimumListWidth, idealWidth: Design.idealListWidth)
			.contextMenu(
				forSelectionType: ObjectRecord.self,
				menu: { items in
					Button("Open \(items.map(\.title).joined(separator: ", "))") {
						self.showSelection = true
					}
				},
				primaryAction: { items in
					self.showSelection = true
				}
			)
		}
		
		private var splitView: some View {
			NavigationSplitView {
				List(self.filteredRecords, id: \.self, selection: self.$selection) { record in
					NavigationLink {
						ArtworkDetail.RecordDetail(record: record, letDismiss: false)
					} label: {
						RecordRow(record: record)
					}
				}
				.listStyle(.sidebar)
				.frame(minWidth: Design.minimumSidebarWidth, idealWidth: Design.idealSidebarWidth)
			} detail: {
				Text("Please make a selection to view more.")
			}
		}
		
		fileprivate var _previousPageButton: some View {
			Button("Previous Page") {
				Task {
					try? await self.perform(.showRecords(forPage: self.viewModel.currentPage - 1))
				}
			}
			.disabled(!self.viewModel.canGoToPreviousPage)
		}
		
		fileprivate var _nextPageButton: some View {
			Button("Next Page") {
				Task {
					try? await self.perform(.showRecords(forPage: self.viewModel.currentPage + 1))
				}
			}
			.disabled(!self.viewModel.canGoToNextPage)
		}
	}
	
	struct RecordRow: View {
		enum Design {
			static let datedLayoutPriority = Double(0.5)
			static let imageMaxWidth = CGFloat(100)
			static let imageMaxHeight = CGFloat(75)
			static let placeholderImageWidth = CGFloat(50)
			static let placeholderImageHeight = CGFloat(45)
			static let peopleLayoutPriority = Double(1)
			static let titleLayoutPriority = Double(1)
		}
		
		var record: ObjectRecord
		
		var body: some View {
			VStack(alignment: .leading) {
				HStack(alignment: .top) {
					if let firstImage = self.record.images?.first {
						AsyncImage(
							url: URL(string: firstImage.baseimageurl),
							content: { image in
								image
									.resizable()
									.frame(maxWidth: Design.imageMaxWidth, maxHeight: Design.imageMaxHeight)
							},
							placeholder: {
								ProgressView()
							}
						)
					} else {
						Image(systemName: "photo")
							.resizable()
							.frame(width: Design.placeholderImageWidth, height: Design.placeholderImageHeight)
					}
					
					VStack(alignment: .leading) {
						Text(self.record.title)
							.bold()
							.font(.body)
							.layoutPriority(Design.titleLayoutPriority)
						
						HStack {
							ForEach(self.record.people ?? [], id: \.self) { person in
								Text(person.displayname)
									.font(.callout)
									.layoutPriority(Design.peopleLayoutPriority)
							}
							
							Spacer()
						}
						
						if let objectnumber = record.objectnumber {
							Text(objectnumber)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
					}
					
					if let dated = self.record.dated {
						Text(dated)
							.layoutPriority(Design.datedLayoutPriority)
					}
					
					Spacer()
					
					if let classification = self.record.classification {
						Text(classification)
							.font(.callout)
							.foregroundStyle(.secondary)
							.italic()
					}
				}
				
				if let creditline = self.record.creditline {
					Text(creditline)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			.lineLimit(1)
		}
	}
}


