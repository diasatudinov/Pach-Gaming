import SwiftUI

class ZZAchievementsViewModel: ObservableObject {
    
    @Published var achievements: [NEGAchievement] = [
        NEGAchievement(image: "achieve1ImagePD", title: "achieve1TextPD", isAchieved: false),
        NEGAchievement(image: "achieve2ImagePD", title: "achieve2TextPD", isAchieved: false),
        NEGAchievement(image: "achieve3ImagePD", title: "achieve3TextPD", isAchieved: false),
        NEGAchievement(image: "achieve4ImagePD", title: "achieve4TextPD", isAchieved: false),
        NEGAchievement(image: "achieve5ImagePD", title: "achieve5TextPD", isAchieved: false),
    ] {
        didSet {
            saveAchievementsItem()
        }
    }
        
    init() {
        loadAchievementsItem()
    }
    
    private let userDefaultsAchievementsKey = "achievementsKeyCB"
    
    func achieveToggle(_ achive: NEGAchievement) {
        guard let index = achievements.firstIndex(where: { $0.id == achive.id })
        else {
            return
        }
        achievements[index].isAchieved.toggle()
        
    }
   
    
    
    func saveAchievementsItem() {
        if let encodedData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsAchievementsKey)
        }
        
    }
    
    func loadAchievementsItem() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsAchievementsKey),
           let loadedItem = try? JSONDecoder().decode([NEGAchievement].self, from: savedData) {
            achievements = loadedItem
        } else {
            print("No saved data found")
        }
    }
}

struct NEGAchievement: Codable, Hashable, Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var isAchieved: Bool
}