//
//  ContentView.swift
//  postman_demo_App
//
//  Created by Roro Solutions on 30/09/22.
//

import SwiftUI

struct ContentView: View {
    @State var userPhNumnber = ""
    
    @State var responseCode = 0
    var body: some View {
        List{
            TextField("Enter phone number", text: $userPhNumnber)
            Button{
                getOtp(number: userPhNumnber)
            }label: {
                Text("get otp")
            }
        }
    }
    func getOtp(number: String){
        struct UploadData: Codable {
            let phoneNumber: String
        }
        guard let url = URL(string: "https://api-v2-dev.eyrus.com/v2/users/otp_request") else {
                    print("Error: cannot create URL")
                    return
        }
        let uploadDataModel = UploadData(phoneNumber: number.self)
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
                    print("Error: Trying to convert model to JSON data")
                    return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform HTTP Request
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            let response = response as? HTTPURLResponse
            if(response?.statusCode == 200){
                responseCode = response!.statusCode
                print(responseCode)
            }else{
                print("wrong post api")
            }
        }.resume()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
