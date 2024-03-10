//
//  ArtworkListCoordinator.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import ComposableArchitecturePattern
import OSLog
import SwiftUI

protocol ArtworkListDataProvider {
	func fetchMuseumArt(forPage: Int) async throws -> ObjectAPIResponse
}

@Observable
class ArtworkListCoordinator: ViewCoordinator {
	var logger: Logger {
		return Logger()
	}
	var provider: any ArtworkListDataProvider
	var viewModel: ArtworkList.ViewModel
	var swipeListener: Any?
	
	init(provider: any ArtworkListDataProvider, viewModel: ArtworkList.ViewModel = .init()) {
		self.provider = provider
		self.viewModel = viewModel
		
		self._swipeEventListener()
	}
	
	deinit {
		#if os(macOS)
		if let swipeListener {
			NSEvent.removeMonitor(swipeListener)
		}
		#endif
	}
	
	@ViewBuilder var view: some View {
		ArtworkList.ContentView(
			viewModel: viewModel,
			perform: self._handle(actions:)
		)
	}
	var state: ViewCoordinatorState = .idle
	
	func load() async {
		guard self.state != .loaded else {
			return
		}
		self.state = .loaded
		do {
			try await self._loadArtwork()
		} catch {
			self.logger.error("Unable to load artwork. ERROR: \(error)")
		}
	}
	
	fileprivate func _handle(actions: ArtworkList.ListActions) async throws {
		switch actions {
			case let .showRecords(forPage):
				try await self._showRecords(for: forPage)
				
			case .refresh:
				try await self._loadArtwork()
		}
	}
	
	/// Checks whether a group is already in the list and whether to fetch them from the provider.
	fileprivate func _showRecords(for page: Int) async throws {
		if !self.viewModel.recordGroups.lazy.contains(where: { $0.page == page }) {
			try await self._fetchRecords(forPage: page)
		} else {
			self.viewModel.currentPage = page
		}
	}
	
	fileprivate func _fetchRecords(forPage: Int) async throws {
		let response = try await self.provider.fetchMuseumArt(forPage: forPage)
		self._updateViewModel(from: response)
	}
	
	fileprivate func _updateViewModel(from response: ObjectAPIResponse) {
		let newGroup = ArtworkList.RecordGroup(page: response.info.page, records: response.records)
		self.viewModel.recordGroups.append(newGroup)
		self.viewModel.currentPage = response.info.page
		self.viewModel.totalPages = response.info.pages
	}
	
	fileprivate func _loadArtwork() async throws {
		let pageToFetch = self.viewModel.currentPage > 0 ? self.viewModel.currentPage : 1
		try await self._fetchRecords(forPage: pageToFetch)
	}
	
	fileprivate func _swipeEventListener() {
		#if os(macOS)
		self.swipeListener = NSEvent.addLocalMonitorForEvents(matching: [.swipe], handler: { [weak self] event in
			if event.phase == .ended {
				// Using mouse buttons, this indicates going forward.
				if event.deltaX == -1.0 {
					if self?.viewModel.canGoToNextPage ?? false {
						let page = (self?.viewModel.currentPage ?? 0) + 1
						Task { [weak self] in
							try? await self?._showRecords(for: page)
						}
					}
				} else if event.deltaX == 1.0 {
					// Using mouse buttons, this indicates going back.
					if self?.viewModel.canGoToPreviousPage ?? false {
						let page = (self?.viewModel.currentPage ?? 0) - 1
						Task { [weak self] in
							try? await self?._showRecords(for: page)
						}
					}
				}
			}
			return event
		})
		#endif
	}
}
