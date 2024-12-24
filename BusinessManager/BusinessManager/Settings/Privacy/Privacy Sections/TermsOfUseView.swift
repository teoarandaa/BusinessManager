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
                    Text("acceptance_terms".localized())
                        .bold()
                    Text("acceptance_terms_content".localized())
                    
                    Text("description_service".localized())
                        .bold()
                    Text("description_service_content".localized())
                    
                    Text("in_app_purchases".localized())
                        .bold()
                    Text("in_app_purchases_content".localized())
                    
                    Text("intellectual_property".localized())
                        .bold()
                    Text("intellectual_property_content".localized())
                    
                    Text("limitation_liability".localized())
                        .bold()
                    Text("limitation_liability_content".localized())
                    
                    Text("changes_terms".localized())
                        .bold()
                    Text("changes_terms_content".localized())
                    
                    Text("termination".localized())
                        .bold()
                    Text("termination_content".localized())
                    
                    Text("governing_law".localized())
                        .bold()
                    Text("governing_law_content".localized())
                    
                    Text("contact_information".localized())
                        .bold()
                    (Text("contact_information_prefix".localized()) +
                    Text("privacy_email".localized())
                        .foregroundColor(.accentColor)
                        .underline())
                        .onTapGesture {
                            if let url = URL(string: "mailto:help.businessmanager@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        }
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
