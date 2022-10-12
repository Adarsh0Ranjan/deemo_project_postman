//
//  ContentView.swift
//  postman_demo_App
//
//  Created by Roro Solutions on 30/09/22.
//

import SwiftUI
struct ContentView: View {
    @State var userPhNumnber = ""
    @State var getOtpResponseCode = 0
    @State var verifyOtpResponseCode = 0
    @State var otp = ""
    @State private var showingRefreshTokenView = false
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("Eyrus Worker App")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                VStack(spacing: 15) {
                    VStack {
                        Text("Sign In Using Mobile")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        TextField("Enter phone number", text: $userPhNumnber)
                            .frame(width: 200, height: 35, alignment: .center)
                            .background(.secondary)
                        Button{
                            getOtp(number: userPhNumnber)
                        }label: {
                            Text(getOtpResponseCode == 200 ? "Resend OTP" : "Send OTP")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .disabled(userPhNumnber.count < 10)
                        if getOtpResponseCode == 200 {
                            Text("Enter One Time Password")
                                .foregroundStyle(.secondary)
                                .font(.subheadline.weight(.heavy))
                                .padding([.top],15)
                            TextField("Enter OTP",text: $otp)
                                .frame(width: 100, height: 30, alignment: .center)
                                .background(.secondary)
                            Button{
                                verifyOtp(number: userPhNumnber, otp: otp)
                            }label: {
                                Text("Verify")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            if(verifyOtpResponseCode == 200){
                                HStack{
                                    Button{
                                        let auth = UserDefaults.standard.auth(forKey: "Auth")
                                        getWorkerInfo(Token: auth!.jsonWebToken.accessToken)
                                    }label: {
                                        Text("Get Worker Info")
                                            .frame(width: 150, height: 30, alignment: .center)
                                    }
                                    Spacer()
                                    Button{
                                        showingRefreshTokenView.toggle()
                                    }label: {
                                        Text("Refresh Token")
                                            .frame(width: 150, height: 30, alignment: .center)
                                    }
                                    .sheet(isPresented: $showingRefreshTokenView) {
                                        RefreshTokenView()
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                Spacer()
                Spacer()
                Spacer()
                
            }
            .padding()
        }
    }
    //getting worker info
    func getWorkerInfo(Token: Any) {
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
    //get otp
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
                getOtpResponseCode = response!.statusCode
            }else{
                print("wrong post api")
            }
        }.resume()
    }
    //verifying OTP
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
            let response = response as? HTTPURLResponse
            if response?.statusCode == 200 {
                verifyOtpResponseCode = response!.statusCode
            }else{
                print("Error: HTTP request failed")
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
                    print(auth.jsonWebToken.refreshToken)
                    UserDefaults.standard.set(auth, forKey: "Auth")
                } catch { print(error) }
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
extension UserDefaults {
    func auth(forKey defaultName: String) -> PrettyJson? {
        guard let data = data(forKey: defaultName) else { return nil }
        do {
            return try JSONDecoder().decode(PrettyJson.self, from: data)
        } catch { print(error); return nil }
    }

    func set(_ value: PrettyJson, forKey defaultName: String) {
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: defaultName)
    }
}
