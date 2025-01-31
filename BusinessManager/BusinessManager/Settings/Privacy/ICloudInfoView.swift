import SwiftUI

struct ICloudInfoView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "icloud")
                            .font(.title)
                            .foregroundStyle(.blue)
                        Text("icloud_sync".localized())
                            .font(.title2)
                            .bold()
                    }
                    .padding(.bottom, 4)
                    
                    Text("icloud_description".localized())
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("how_it_works".localized()) {
                FeatureRow(
                    icon: "arrow.triangle.2.circlepath.icloud",
                    title: "automatic_sync".localized(),
                    description: "automatic_sync_description".localized()
                )
                
                FeatureRow(
                    icon: "network",
                    title: "multi_device".localized(),
                    description: "multi_device_description".localized()
                )
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "secure_sync".localized(),
                    description: "secure_sync_description".localized()
                )
            }
            
            Section("how_to_disable".localized()) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("disable_steps".localized())
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. \("open_settings".localized())")
                        Text("2. \("tap_apple_id".localized())")
                        Text("3. \("tap_icloud".localized())")
                        Text("4. \("tap_icloud_storage".localized())")
                        Text("5. \("disable_business_manager".localized())")
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("icloud_info".localized())
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ICloudInfoView()
    }
} 
