
import Foundation

final class SlimeAppUserDefaults {
    private static let storage = UserDefaults.standard
    //MARK: - Sounds
    static var isSound: Bool {
        get { storage.value(forKey: #function) as? Bool ?? true }
        set { storage.set(newValue, forKey: #function) }
    }
    //MARK: - Best scores
    static var bestScore: Int {
        get {storage.value(forKey: #function) as? Int ?? 0}
        set {storage.set(newValue, forKey: #function)}
    }
}
