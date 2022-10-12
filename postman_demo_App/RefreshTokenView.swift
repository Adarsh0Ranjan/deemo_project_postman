//
//  RefreshTokenView.swift
//  postman_demo_App
//
//  Created by Roro Solutions on 12/10/22.
//

import SwiftUI

struct RefreshTokenView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button{
            let auth = UserDefaults.standard.auth(forKey: "Auth")
            refreshtokenModel(Token: auth!.jsonWebToken.refreshToken)
        }label: {
            Text("get token")
        }
        Button("Press to dismiss") {
            dismiss()
        }
    }
    func refreshtokenModel(Token: String) {
        guard let url = URL(string:"https://api-v2-dev.eyrus.com/v2/users/refresh_token") else {
            print("Error: cannot create URL")
            return
        }
        // Create model
    struct UploadData:Codable {
            let refreshToken: String
        }
        // Add data to the model
    let uploadDataModel = UploadData(refreshToken: Token )
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
                do {
                    let auth = try JSONDecoder().decode(PrettyJson.self, from: data)
                    print("Acess Token:\(auth.jsonWebToken.accessToken)")
                    print("Refresh Token:\(auth.jsonWebToken.refreshToken)")
                    UserDefaults.standard.set(auth, forKey: "Auth")
                } catch { print(error) }
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
}

struct RefreshTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshTokenView()
    }
}
