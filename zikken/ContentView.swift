import SwiftUI

struct ContentView: View {
    @State var data: [TestModel] = []
    
    var e:[[String]]=[["a"]]
    
    var body: some View {
        VStack {
        if data.isEmpty {
            Text("Loading...")
                .padding()
        } else {
            List(data, id: \.id) { person in
                Text(person.name)
            }
        }
    }
    .onAppear {
        fetchDataFromAPI()
    }
    }
    
    func fetchDataFromAPI() {
        guard let url = URL(string: "http://localhost:8000/people") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonArray = json as? [[String: Any]] {
                        for person in jsonArray {
                            if let id = person["id"] as? Int,
                               let name = person["name"] as? String,
                               let age = person["age"] as? Int {
                                // データを使用する処理
                                print("ID: \(id), Name: \(name), Age: \(age)")
                                
                                self.data.append(TestModel(id: id, age: age, name: name))
                            }
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TestModel: Codable,Hashable {
    var id: Int
    var age: Int
    var name: String
}

