import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    // Terms Icon
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor)
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "text.document")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .padding(50)
                        )
                        .padding(.bottom, 20)
                    Text("terms_acceptance_title".localized())
                        .bold()
                    Text("terms_acceptance_content".localized())
                    
                    Text("service_description_title".localized())
                        .bold()
                    Text("service_description_content".localized())
                    
                    Text("in_app_purchases_title".localized())
                        .bold()
                    Text("in_app_purchases_content".localized())
                    
                    Text("intellectual_property_title".localized())
                        .bold()
                    Text("intellectual_property_content".localized())
                    
                    Text("limitation_of_liability_title".localized())
                        .bold()
                    Text("limitation_of_liability_content".localized())
                    
                    Text("changes_to_terms_of_use_title".localized())
                        .bold()
                    Text("changes_to_terms_of_use_content".localized())
                    
                    Text("termination_title".localized())
                        .bold()
                    Text("termination_content".localized())
                    
                    Text("governing_law_title".localized())
                        .bold()
                    Text("governing_law_content".localized())
                    
                    Text("contact_information_title".localized())
                        .bold()
                    Text("terms_contact_info".localized())
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("terms_of_use".localized())
        }
    }
}

#Preview {
    TermsOfUseView()
}
