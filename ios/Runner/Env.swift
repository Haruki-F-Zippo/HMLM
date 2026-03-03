import Foundation

struct Env {
    static var googleMapApiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
              !key.isEmpty,
              key != "YOUR_GOOGLE_MAPS_API_KEY" else {
            fatalError("GOOGLE_MAPS_API_KEY is not configured. Set it in ios/Runner/Info.plist for local dev or via build settings in CI.")
        }
        return key
    }
}
