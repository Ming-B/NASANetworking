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
        
        if let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY") {
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
    @State var fetchingComic = false
    @State var NasaModel = NasaImageModel()
    
    func loadComic() {
        fetchingComic = true
        Task {
            await NasaModel.refresh()
            fetchingComic = false
        }
    }
    
    var body: some View {
        VStack {
            Text("Picture of the Day")
                .font(.title)
            Text(NasaModel.picture?.title ?? "")
            AsyncImage(url:NasaModel.imgURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode:.fit)
            } placeholder: {
                if fetchingComic {
                    ProgressView()
                }
            }
            Spacer()
            Button("Get APOD") {
                loadComic()
            }
            .disabled(fetchingComic)
            
        }
        .padding()
        .onAppear() {
            loadComic()
        }
    }
}


#Preview {
    ComicView()
}
