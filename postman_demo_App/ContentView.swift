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
    @State var otp = ""
    @State var token = ""
    var body: some View {
        List{
            TextField("Enter phone number", text: $userPhNumnber)
            Button{
                getOtp(number: userPhNumnber)
            }label: {
                Text("get otp")
            }
            if responseCode == 200{
                TextField("Enter otp",text: $otp)
                Button{
                    verifyOtp(number: userPhNumnber, otp: otp)
                }label: {
                    Text("Verify")
                }
                TextField("put token ",text: $token)
                Button{
                    getWorkerInfo(Token: token)
                }label: {
                    Text("get worker info")
                }
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
        let uploadDataModel = UploadData(phoneNumber: number)
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
            guard let _ = data else {
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
    func verifyOtp(number: String, otp: String) {
            guard let url = URL(string: "https://api-v2-dev.eyrus.com/v2/users/otp_verify") else {
                print("Error: cannot create URL")
                return
            }
            // Create model
            struct UploadData: Codable {
                let phoneNumber: String
                let code: String
                
            }
            // Add data to the model
        let uploadDataModel = UploadData(phoneNumber: number, code: otp)
            // Convert model to JSON data
            guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
            request.httpBody = jsonData
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
                guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return
                }
                do {
                    guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        print("Error: Cannot convert data to JSON object")
                        return
                    }
                    guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                        print("Error: Cannot convert JSON object to Pretty JSON data")
                        return
                    }
                    guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                        print("Error: Couldn't print JSON in String")
                        return
                    }
                    print(prettyPrintedJson)
                } catch {
                    print("Error: Trying to convert JSON data to string")
                    return
                }
            }.resume()
    }
    func getWorkerInfo(Token: String) {
        guard let url = URL(string: "https://api-v2-dev.eyrus.com/v2/users/me/worker_profile") else {
            print("Error: cannot create URL")
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let acessToken = Token
        request.setValue("Bearer \(acessToken)",
                         forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
                print(prettyPrintedJson)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
