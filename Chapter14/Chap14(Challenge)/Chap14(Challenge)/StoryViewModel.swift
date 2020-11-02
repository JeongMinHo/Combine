//
//  StoryViewModel.swift
//  Chap14(Challenge)
//
//  Created by 정민호 on 2020/11/02.
//

import Foundation
import Combine
import SwiftUI

class StoryViewModel: ObservableObject {
	
	private let api = API()
	private var subscriptions = Set<AnyCancellable>()
	
	@Published var allStories: [Story] = []
	@Published var filter = [String]()
	@Published var error: API.Error? = nil
	
	var stories: [Story] {
		guard !filter.isEmpty else {
			return allStories
		}
		
		return allStories
			.filter { story -> Bool in
				return filter.reduce(false) { isMatch, keyword -> Bool in
					return isMatch || story.title.lowercased().contains(keyword)
				}
			}
	}
	
	func fetchStories() {
		api
			.stories()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case .failure(let error) = completion {
					self.error = error
				}
			}, receiveValue: { stories in
				self.allStories = stories
				self.error = nil
			})
			.store(in: &subscriptions)
	}
}
