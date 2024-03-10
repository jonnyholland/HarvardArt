//
//  Application.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import OSLog
import SwiftUI

@Observable
class Application {
	var artworkListProvider: any ArtworkListDataProvider
	
	init(artworkListProvider: any ArtworkListDataProvider) {
		self.artworkListProvider = artworkListProvider
		self.artworkListCoordinator = ArtworkListCoordinator(provider: artworkListProvider)
	}
	
	var artworkListCoordinator: ArtworkListCoordinator
	var logger: Logger {
		return Logger()
	}
	var state: ApplicationState = .idle
	
	@ViewBuilder var view: some View {
		switch self.state {
			case .idle:
				ProgressView()
			case .ready:
				NavigationStack {
					self.artworkListCoordinator.view
				}
		}
	}
	
	func reactToSceneChange(oldScene: ScenePhase, newScene: ScenePhase) {
		switch newScene {
			case .active:
				self.logger.debug("\(Date()) - App active")
				Task {
					await self.artworkListCoordinator.load()
				}
				self.state = .ready
			default:
				self.logger.debug("\(Date()) - App in background or inactive scene")
				self.state = .idle
		}
	}
}

enum ApplicationState {
	case idle
	case ready
}
