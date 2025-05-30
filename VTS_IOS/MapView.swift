import SwiftUI
import MapKit
import CoreLocation

public struct MapView: View {
    @ObservedObject var authentication: UserAuthentication
    @StateObject private var propertyService = PropertyService()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showingAddProperty = false
    @State private var selectedProperty: Property?
    @State private var showingPropertyDetails = false
    @State private var showingInviteForm = false
    @State private var inviteEmail = ""
    @State private var invitePhone = ""
    @State private var isInviting = false
    @State private var showingInviteSuccess = false
    @State private var longPressLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // Map view
                Map(coordinateRegion: $region, annotationItems: propertyService.properties) { property in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude)) {
                        VStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.red)
                                .background(Circle().fill(.white).frame(width: 30, height: 30))
                                .onTapGesture {
                                    selectedProperty = property
                                    showingPropertyDetails = true
                                }
                            Text(property.name)
                                .font(.caption)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(4)
                        }
                    }
                }
                .onLongPressGesture(minimumDuration: 1) { location in
                    if authentication.currentUsername == "admin" {
                        // Convert tap point to map coordinate
                        let tapPoint = location
                        guard let mapCoordinate = convertToCoordinate(tapPoint) else { return }
                        
                        longPressLocation = mapCoordinate
                        showingAddProperty = true
                    }
                }
                
                // Admin Actions Button
                if authentication.currentUsername == "admin" {
                    Button(action: {
                        showingAddProperty = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .background(Color.white.clipShape(Circle()))
                            .foregroundColor(Color.blue)
                            .padding()
                    }
                }
            }
            .navigationTitle("Properties")
            .sheet(isPresented: $showingAddProperty) {
                AddPropertyView(
                    propertyService: propertyService,
                    isPresented: $showingAddProperty,
                    initialCoordinate: longPressLocation
                )
            }
            .sheet(isPresented: $showingPropertyDetails) {
                if let property = selectedProperty {
                    PropertyDetailView(
                        property: property,
                        propertyService: propertyService,
                        isAdmin: authentication.currentUsername == "admin",
                        showingInviteForm: $showingInviteForm
                    )
                }
            }
            .sheet(isPresented: $showingInviteForm) {
                if let property = selectedProperty {
                    InviteTenantView(
                        property: property,
                        propertyService: propertyService,
                        isPresented: $showingInviteForm,
                        showingSuccess: $showingInviteSuccess
                    )
                }
            }
            .alert("Invitation Sent", isPresented: $showingInviteSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The tenant has been invited to download the app with temporary credentials.")
            }
        }
    }
    
    // Helper function to convert tap location to map coordinate
    func convertToCoordinate(_ point: CGPoint) -> CLLocationCoordinate2D? {
        // This would need a proper implementation in a real app
        // For now, we'll just use a hard-coded coordinate near the center of the map
        return CLLocationCoordinate2D(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )
    }
}

struct AddPropertyView: View {
    @ObservedObject var propertyService: PropertyService
    @Binding var isPresented: Bool
    var initialCoordinate: CLLocationCoordinate2D?
    
    @State private var name = ""
    @State private var address = ""
    @State private var description = ""
    @State private var latitude: Double = 47.6062
    @State private var longitude: Double = -122.3321
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Location")) {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        Text("\(latitude, specifier: "%.6f")")
                    }
                    HStack {
                        Text("Longitude")
                        Spacer()
                        Text("\(longitude, specifier: "%.6f")")
                    }
                }
            }
            .onAppear {
                if let coordinate = initialCoordinate {
                    latitude = coordinate.latitude
                    longitude = coordinate.longitude
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        propertyService.addProperty(
                            name: name,
                            address: address,
                            description: description,
                            latitude: latitude,
                            longitude: longitude,
                            createdBy: "admin"
                        )
                        isPresented = false
                    }
                    .disabled(name.isEmpty || address.isEmpty)
                }
            }
        }
    }
}

struct PropertyDetailView: View {
    let property: Property
    @ObservedObject var propertyService: PropertyService
    let isAdmin: Bool
    @Binding var showingInviteForm: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text(property.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(property.address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom)
                    
                    Text(property.description)
                        .padding(.bottom)
                    
                    Divider()
                    
                    if let email = property.tenantEmail {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Tenant Email: \(email)")
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if let phone = property.tenantPhone {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Tenant Phone: \(phone)")
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if isAdmin {
                        Button(action: {
                            showingInviteForm = true
                        }) {
                            HStack {
                                Image(systemName: "envelope.badge.fill")
                                Text(property.tenantEmail == nil && property.tenantPhone == nil ? "Invite Tenant" : "Change Tenant")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Property Details", displayMode: .inline)
        }
    }
}

struct InviteTenantView: View {
    let property: Property
    @ObservedObject var propertyService: PropertyService
    @Binding var isPresented: Bool
    @Binding var showingSuccess: Bool
    
    @State private var email = ""
    @State private var phone = ""
    @State private var isInviting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Invite by Email")) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Invite by Phone Number")) {
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section {
                    Button(action: {
                        isInviting = true
                        
                        propertyService.inviteTenant(
                            property: property,
                            email: email.isEmpty ? nil : email,
                            phone: phone.isEmpty ? nil : phone
                        ) { success in
                            isInviting = false
                            if success {
                                isPresented = false
                                showingSuccess = true
                            }
                        }
                    }) {
                        if isInviting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Send Invitation")
                        }
                    }
                    .disabled(isInviting || (email.isEmpty && phone.isEmpty))
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle("Invite Tenant", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(authentication: UserAuthentication())
    }
}