//
//  ContentView.swift
//  Chap14(Challenge)
//
//  Created by 정민호 on 2020/11/02.
//

import SwiftUI
import Combine

struct ContentView: View {
	
	@ObservedObject var model: StoryViewModel
	
	init(model: StoryViewModel) {
		self.model = model
		model.fetchStories()
		print("Here")
		
	}
	
    var body: some View {
		
		NavigationView {
			List() {
				ForEach(self.model.stories) { story in
					VStack(alignment: .leading) {
						Text(story.title)
							.font(.title3)
							.foregroundColor(.orange)
							
						Text(story.by)
							.font(.subheadline)
					}
				}
				
			}.navigationBarTitle(Text("Latest Stories"))
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(model: StoryViewModel())
    }
}
