//
//  ComicView.swift
//  NASANetworking
//
//  Created by Ming Bian on 2/28/25.
//

import SwiftUI


struct NasaImage: Codable {
    
    var date: String
    var explanation: String
    var title: String
    var url: String
    var hdurl: String
    
}

class NasaImageModel {
    var picture: NasaImage?
    var imgURL: URL?
    var refreshDate: Date?
    
    func refresh() async {
        self.picture = await getPicture()
    }
    
    private func getPicture() async -> NasaImage? {
        
        
        let session = URLSession(configuration: .default)
        
        let tempKey = "dOR3ZJ2YwfP4FgLBbajf6R7eazZY3Wz7wvUi7S6A"
        
        
        
        if let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(tempKey)") {
            let request = URLRequest(url: url)
            
            do {
                let(data, _) = try await session.data(for:request)
                let decoder = JSONDecoder()
                let image = try decoder.decode(NasaImage.self, from: data)
                self.imgURL = URL(string: image.url)
                self.refreshDate = Date()
                return image
            }
            
            catch {
                print(error)
            }
        }
        return nil
    }
    
}



struct ComicView: View {
    @State var fetchingImage = false
    @State var NasaModel = NasaImageModel()
    
    func loadImage() {
        fetchingImage = true
        Task {
            await NasaModel.refresh()
            fetchingImage = false
        }
    }
    
    var body: some View {
        VStack {
            Text("Astronomy Picture of the Day")
                .font(.title)
            
            Text(NasaModel.picture?.title ?? "")
            AsyncImage(url:NasaModel.imgURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode:.fit)
            } placeholder: {
                if (fetchingImage) {
                    ProgressView()
                }
            }
            Spacer()
            Button{
                loadImage()
                
            } label: {
                Text("Get APOD")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width:360, height:44)
                    .background(Color(.systemBlue))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical)
            }
            .disabled(fetchingImage)
            
        }
        .padding()
        .onAppear() {
            loadImage()
        }
    }
}


#Preview {
    ComicView()
}
