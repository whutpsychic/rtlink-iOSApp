import SwiftUI


enum WebLink: String, Identifiable{
    
    case url1 = "http://www.baidu.com"
    case url2 = "http://www.tencent.com"
    case url3 = "http://www.sina.com"
    case url4 = "http://192.168.1.10:8082/mobile"
    
    var id:UUID{
        UUID()
    }
}

struct Webviews: View {
    
    @State private var link: WebLink?
    
    var body: some View {
        NavigationStack {
            List{
                Image("about").resizable().scaledToFit()
                
                Section{
                    
                    Link(destination:URL(string: WebLink.url1.rawValue)!,label: {
                        Label("Rate us on App Store", image: "store").foregroundStyle(.primary)
                    })
                    
                    
                    Label("Tell us your feedback", image: "chat").onTapGesture {
                        link = .url1
                    }
                        
                }
                
                Section{
                    Label("Twitter", image: "twitter").onTapGesture {
                        link = .url2
                    }
                    
                    Label("Facebook", image: "facebook").onTapGesture {
                        link = .url3
                    }
                    
                    Label("Instagram", image: "instagram").onTapGesture {
                        link = .url4
                    }
                    
                }
            }.listStyle(.grouped)
                .navigationTitle("About").navigationBarTitleDisplayMode(.automatic)
                .sheet(item: $link){ item in
                if let url = URL(string: item.rawValue){
                    WebView0(url: url)
                }
            }
            
            
        }
    }
}



#Preview {
    Webviews()
}
