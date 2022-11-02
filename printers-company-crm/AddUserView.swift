//
//  AddUserView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import SwiftUI

struct AddUserView: View {
    private let passwordLength = 12
    
    @ObservedObject private var employees: Employees
    @State private var name = ""
    @State private var surname = ""
    @State private var login = ""
    @State private var password = ""
    @State private var secured = true
    @StateObject private var mobilePhone = NumberLimiter(limit: 11)
    @State private var email = ""
    @State private var positionCode = 1
    @State private var positionsCodes = DatabaseAPI.getPositionCodes()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @Environment(\.dismiss) private var dismiss
    
    private let phoneFieldFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    init(employees: Employees) {
        self.employees = employees
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("User name", text: $name)
                        .autocorrectionDisabled(true)
                    TextField("User surname", text: $surname)
                        .autocorrectionDisabled(true)
                }
                Section {
                    TextField("Login", text: $login)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    HStack {
                        if secured {
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                            
                        } else {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)

                        }
                        Button {
                            secured.toggle()
                        } label: {
                            if secured {
                                Image(systemName: "eye")
                            } else {
                                Image(systemName: "eye.slash")
                            }
                        }
                    }
                    Button("Generate password") {
                        password = generatePassword(length: 10)
                    }
                }
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Phone number", value: $mobilePhone.value, formatter: phoneFieldFormatter)
                        .autocorrectionDisabled(true)
                        .keyboardType(.numberPad)
                    Picker("Position code", selection: $positionCode) {
                        ForEach(Array(positionsCodes.keys), id: \.self) {
                            if let value = positionsCodes[$0] {
                                Text(value)
                            }
                        }
                    }
                    Button("Submit") {
                        do {
                            try DatabaseAPI.createUser(name: name, surname: surname,
                                                       login: login, password: password,
                                                       mobilePhone: mobilePhone.value, email: email,
                                                       positionCode: positionCode)
                            var role = Role.admin
                            switch positionCode {
                            case 1:
                                role = Role.manager
                            case 2:
                                role = Role.worker
                            default:
                                role = Role.admin
                            }
                            employees.employee_list.append(Employee(name: name, surname: surname,
                                                                    login: login, mobile: mobilePhone.value,
                                                                    email: email, role: role))
                            alertTitle = "New user created"
                            alertMessage = "Do not forget to give login and password to the employee"
                        }
                        catch {
                            alertTitle = "Error"
                            alertMessage = "Error occurred"
                        }
                        showingAlert.toggle()
                    }
                }
            }
            .navigationTitle("Create a new user")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func generatePassword(length: Int) -> String{
        let elements = "abcdefghijklmonpqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@#%$()"
        var password = ""
        for _ in 0..<length {
            password.append(elements.randomElement()!)
        }
        return password
    }
}
