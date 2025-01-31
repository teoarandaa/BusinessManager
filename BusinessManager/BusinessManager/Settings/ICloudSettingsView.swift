import SwiftUI

struct ICloudSettingsView: View {
    @AppStorage("iCloudSync") private var iCloudSync = false
    @AppStorage("isNetworkAvailable") private var isNetworkAvailable = false
    @AppStorage("lastSyncDate") private var lastSyncDate = Date()
    @AppStorage("isNetworkUnstable") private var isNetworkUnstable = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: getCloudIcon())
                        .foregroundStyle(getCloudIconColor())
                    VStack(alignment: .leading) {
                        Text("icloud_status".localized())
                            .font(.headline)
                        if !isNetworkAvailable {
                            Text("network_unavailable".localized())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else if isNetworkUnstable {
                            Text("network_unstable".localized())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else if !iCloudSync {
                            Text("icloud_disabled".localized())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("last_sync".localized() + ": ")
                            + Text(lastSyncDate, style: .date)
                            + Text(" ")
                            + Text(lastSyncDate, style: .time)
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("how_icloud_works".localized())
                        .font(.headline)
                    
                    Text("icloud_explanation".localized())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("how_to_disable".localized())
                        .font(.headline)
                    
                    Text("disable_icloud_steps".localized())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("open_settings".localized(), systemImage: "gear")
                }
            }
        }
        .navigationTitle("icloud_settings".localized())
    }
    
    private func getCloudIcon() -> String {
        if !isNetworkAvailable {
            return "xmark.icloud"
        } else if isNetworkUnstable {
            return "exclamationmark.icloud"
        } else if iCloudSync {
            return "checkmark.icloud.fill"
        } else {
            return "xmark.icloud"
        }
    }
    
    private func getCloudIconColor() -> Color {
        if !isNetworkAvailable || !iCloudSync {
            return .red
        } else if isNetworkUnstable {
            return .yellow
        } else {
            return .green
        }
    }
} 