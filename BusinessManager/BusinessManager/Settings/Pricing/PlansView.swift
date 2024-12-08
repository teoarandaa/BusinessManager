import SwiftUI

struct PlansView: View {
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    // Plans Icon
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor)
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "rosette")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .padding(50)
                        )
                        .padding(.bottom, 20)
                    
                    // Aquí puedes añadir el contenido de los planes
                    Text("Nothing here yet")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Subscription Plans")
        }
    }
}

#Preview {
    PlansView()
}
