//
//  ContentView.swift
//  DWDWatch
//
//  Created by Léon Friedmann on 06.07.21.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewViewModel()
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.getImages()
            }, label: {
                Text("Refresh")
            })
            Picker(selection: $viewModel.selectedImage, label: Text("Image")) {
                ForEach(viewModel.images.sorted(), id: \.self) { image in
                    Text("\(image.date)").tag(image.id)
                }
            }
            if let imageId = viewModel.selectedImage,
               let image = viewModel.images.first(where: { $0.id == imageId }){
                Image(nsImage: image.image)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
