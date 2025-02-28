/// Модель отзыва.
struct Review: Decodable {

    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Аватар пользователя
    let avatar: String?
    /// Имя пользователя
    let firstName, lastName: String
    /// Рейтинг отзыва
    let rating: Int
    /// Фотографии из отзыва
    let photosURL: [PhotosURL]?
    /// Полное имя пользователя
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    /// CodingKeys для корректной обработки json
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar = "avatar_url"
        case photosURL = "photos_url"
        case rating, text, created
    }
    
    /// Модель массива фото из отзыва
    struct PhotosURL: Codable {
        let type: String
        let url: String
    }
    
    
}
