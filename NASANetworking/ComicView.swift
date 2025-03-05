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
    var hdurl: String?
    //var media_type: String
    
}


//image model for a nasa image of the day
//@params: array of images(to contain the past few days)
@Observable
class NasaImageModel {
    
    //ask if i even need the nasamodel, or can i get away with just using the struct and instantiating it
    
    var pictures: [NasaImage] = []
    //async function that awaits get picturs
    //refrehes the screen to fetch the new pictures of the day for the past 5 days
    func refresh() async {
        
        let pastDates = getPastFiveDays()
        
        for date in pastDates {
            if let picture = await getPicture(for: date) {
                self.pictures.append(picture)
            }
        }
        
    }
    
    
    //async function that returns the picture of the day
    private func getPicture(for date: String) async -> NasaImage? {
        let session = URLSession(configuration: .default)
        
        
        let key = "dOR3ZJ2YwfP4FgLBbajf6R7eazZY3Wz7wvUi7S6A"
        
        if let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=\(key)&date=\(date)") {
            let request = URLRequest(url: url)
            
            do {
                let(data, _) = try await session.data(for:request)
                let decoder = JSONDecoder()
                let image = try decoder.decode(NasaImage.self, from: data)
                return image
                
            }
            catch {
                print(error)
            }
        }
        return nil
    }
    
    
    private func getPastFiveDays() -> [String] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var pastDates: [String] = []
        
        for i in 0...5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                pastDates.append(dateFormatter.string(from: date))
                
            }
        }
        
        return pastDates
    }
    
    
    //function to calculate the day that was 5 days before current
    private func getStartDate(date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let newDate = calendar.date(byAdding: .day, value: -5, to: date) {
            return dateFormatter.string(from: newDate)
        }
        
        return dateFormatter.string(from: date)
        
        
    }
    
    
}


//detail view for whenever user taps on a thumbnail in the main screen
//instance of NasaImage is used. Simple scroll view that has the article's title, image and explanation
struct DetailView: View {
    let apod: NasaImage
    
    var body: some View {
        ScrollView {
            VStack {
                Text(apod.title)
                    .font(.title)
                    .padding()
                
                AsyncImage(url: URL(string: apod.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                } placeholder: {
                    ProgressView()
                }
                
                
                Text(apod.explanation)
                    .font(.body)
                    .padding()
                
            }
        }
    }
    
    
}


//list of past 5 days worth of APODS, structured in a way such that you can navigate to a more detailed view
//click on thumbnail to go into detailed view
struct ComicView: View {
    @State var nasaModel = NasaImageModel()
    @State var fetchingImage = false
    
    func loadImage() {
        fetchingImage = true
        Task {
            await nasaModel.refresh()
            fetchingImage = false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("NASA APOD")
                    .font(.headline)
                    .padding()
                
                List(nasaModel.pictures, id: \.date) { picture in
                    NavigationLink{
                        DetailView(apod: picture)
                    } label: {
                        HStack {
                            AsyncImage(url: URL(string: picture.url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                            
                            Text(picture.title)
                                .font(.headline)
                        }
                    }
                    
                }
                .listStyle(.plain)
                
                
                Button {
                    loadImage()
                } label: {
                    Text("Get APOD")
                }
                .disabled(fetchingImage)
            }
        }
        .onAppear() {
            loadImage()
        }
        .padding()
    }
    
}

#Preview {
    ComicView()
}

