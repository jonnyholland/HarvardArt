//
//  ArtworkDetail.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import ComposableArchitecturePattern
import SwiftUI

enum ArtworkDetail {
	struct RecordDetail: View {
		enum Design {
			static let colorWheelMaxWidth = CGFloat(300)
			static let viewAlignment = Alignment.leading
			static let viewMinWidth = CGFloat(350)
			static let viewIdealWidth = CGFloat(550)
			static let viewMaxWidth = CGFloat.infinity
			static let viewMinHeight = CGFloat(300)
			static let viewMaxHeight = CGFloat.infinity
		}
		
		@Environment(\.dismiss) private var dismiss
		
		let record: ObjectRecord
		let letDismiss: Bool
		
		private var colors: [ObjectColor] {
			return self.record.colors ?? []
		}
		private var colorGradient: Gradient? {
			guard !self.colors.isEmpty else {
				return nil
			}
			
			return Gradient(colors: self.colors.compactMap({ Color(hex: $0.color) }))
		}
		
		var body: some View {
			ScrollViewReader { proxy in
				ScrollView {
					VStack(alignment: .leading, spacing: 8) {
						if let images = self.record.images {
							ImageViewer(images: images)
								.padding(.bottom)
								.id("TOP")
						}
						
						AlignedLabel("Dated") {
							Text(self.record.dated ?? "")
						}
						
						AlignedLabel("Classification") {
							Text(self.record.classification ?? "")
						}
						
						AlignedLabel("Technique") {
							Text(self.record.technique ?? "")
						}
						
						AlignedLabel("Artists") {
							HStack {
								if self.record.people?.isEmpty ?? true {
									ForEach(self.record.people ?? [], id: \.self) { person in
										Text(person.displayname)
									}
								} else {
									Text("Unknown")
								}
							}
						}
						
						AlignedLabel("Colors") {
							self.colorWheel
						}
						
						Spacer()
							.id("BOTTOM")
					}
					.focusable()
					.padding()
					.navigationTitle(self.record.title)
					.frame(minWidth: Design.viewMinWidth, idealWidth: Design.viewIdealWidth, maxWidth: Design.viewMaxWidth, minHeight: Design.viewMinHeight, maxHeight: Design.viewMaxHeight, alignment: Design.viewAlignment)
					.toolbar {
						if self.letDismiss {
							Button("Done", role: .cancel) {
								self.dismiss()
							}
						}
						
						ShareLink(
							item: self.record.url,
							subject: Text(self.record.title),
							message: Text("Tell others about this interesting artwork piece.")
						)
					}
					.onKeyPress(keys: [.upArrow, .downArrow], action: { press in
						if press.key == .downArrow {
							proxy.scrollTo("BOTTOM", anchor: .bottom)
						} else if press.key == .upArrow {
							proxy.scrollTo("TOP", anchor: .top)
						}
						
						return .handled
					})
				}
			}
		}
		
		@ViewBuilder
		private var colorWheel: some View {
			if let colorGradient {
				Circle()
					.fill(AngularGradient(gradient: colorGradient, center: .center))
					.frame(maxWidth: Design.colorWheelMaxWidth)
			}
		}
	}
	
	struct ImageViewer: View {
		let images: [ObjectImage]
		
		init(images: [ObjectImage]) {
			self.images = images
			self._currentImage = State(initialValue: images.first)
		}
		
		@State private var currentImage: ObjectImage?
		private var canGoToPreviousImage: Bool {
			guard !self.images.isEmpty else {
				return false
			}
			
			return self.images.first != self.currentImage
		}
		
		private var canGoToNextImage: Bool {
			guard !self.images.isEmpty else {
				return false
			}
			
			return images.last != self.currentImage
		}
		
		var body: some View {
			HStack {
				if self.images.count > 1 {
					self.previousButton
				}
				
				if let currentImage {
					RecordImage(image: currentImage)
				}
				
				if self.images.count > 1 {
					self.nextButton
				}
			}
		}
		
		fileprivate var previousButton: some View {
			Button {
				guard let currentImage, let currentIndex = self.images.lazy.firstIndex(of: currentImage) else {
					return
				}
				let previousIndex = self.images.index(before: currentIndex)
				self.currentImage = self.images[previousIndex]
			} label: {
				Image(systemName: "chevron.left")
			}
			.buttonStyle(.plain)
			.disabled(!self.canGoToPreviousImage)
		}
		
		fileprivate var nextButton: some View {
			Button {
				guard let currentImage, let currentIndex = self.images.lazy.firstIndex(of: currentImage) else {
					return
				}
				let nextIndex = self.images.index(after: currentIndex)
				self.currentImage = self.images[nextIndex]
			} label: {
				Image(systemName: "chevron.right")
			}
			.buttonStyle(.plain)
			.disabled(!self.canGoToNextImage)
		}
	}
	
	struct RecordImage: View {
		enum Design {
			static let placeholderWidth = CGFloat(150)
			static let placeholderHeight = CGFloat(150)
		}
		
		let image: ObjectImage
		
		var body: some View {
			AsyncImage(
				url: URL(string: image.baseimageurl),
				content: { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
				},
				placeholder: {
					Image(systemName: "photo")
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: Design.placeholderWidth, height: Design.placeholderHeight)
				}
			)
		}
	}
}
