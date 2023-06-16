import SwiftUI
import MapKit
import Foundation
import Combine

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    var completer: MKLocalSearchCompleter
    @Published var completions: [MKLocalSearchCompletion] = []
    var cancellable: AnyCancellable?
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
        completer.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
}

extension MKLocalSearchCompletion: Identifiable {}

struct SearchBar: UIViewRepresentable {

    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
struct MapSearchBar: View {
    @ObservedObject var locationSearchService: LocationSearchService
    @Binding var selectedLocation:String
    @State private var selectedLocationTitle = ""
        var body: some View {
                VStack {
                    SearchBar(text: $locationSearchService.searchQuery)
                    if !selectedLocation.isEmpty {
                        Text("Selected Location is \(selectedLocation)")
                        Divider()
                    }
                    if !locationSearchService.searchQuery.isEmpty {
                        List(locationSearchService.completions) { completion in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(completion.title)
                                    Text(completion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                if completion.title == selectedLocationTitle {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .onTapGesture {
                                if selectedLocation != completion.subtitle {
                                    selectedLocation = completion.subtitle
                                    selectedLocationTitle = completion.title
                                }
                                else {
                                    selectedLocation = ""
                                }
                            }
                        }
                    }
                }
        }
}


struct MapSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchBarWrapper()
    }
    
    struct MapSearchBarWrapper: View {
        @State var selectedLocation = ""
        let locationSearchService = LocationSearchService()
        
        var body: some View {
            MapSearchBar(locationSearchService: locationSearchService, selectedLocation: $selectedLocation)
        }
    }
}
