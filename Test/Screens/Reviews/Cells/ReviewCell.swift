import UIKit

protocol ReviewCellDelegate: AnyObject {
    func didTapShowMore(for rewiewId: UUID)
    func collectionView(collectionviewcell: PhotoCell?, index: Int, didTappedInTableViewCell: ReviewCell)
}

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Рейтинг отзыва
    var rating: Int
    /// Аватар пользователя
    var avatar: String?
    /// Полное имя пользователя
    var fullName: NSAttributedString
    /// Массив картинок из отзыва
    var photos: [String]?
    /// Максимальное отображаемое количество строк текста. По умолчанию 3
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.avatarImageView.imageFromServerURL(avatar ?? "", placeHolder: UIImage(named: "avatar"))
        cell.ratingImageView.image = RatingRenderer().ratingImage(rating)
        cell.fullNameLabel.attributedText = fullName
        cell.photoCollectionView?.reloadData()
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    weak var delegate: ReviewCellDelegate?
    
    var selectedPhotoUrl: String?
    
    fileprivate var config: Config?
    
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let fullNameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewPhotoImageView = UIImageView()
    fileprivate let photosView = UIView()
    fileprivate var photoCollectionView: UICollectionView?
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        avatarImageView.frame = layout.avatarImageViewFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        fullNameLabel.frame = layout.fullNameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewPhotoImageView.frame = layout.reviewPhotoImageViewFrame
        photoCollectionView?.frame = layout.photoCollectionViewFrame
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupAvatarImageView()
        setupRatingImageView()
        setupFullnameLabel()
        setupPhotoCollectionView()
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(showMoreButtonTapped), for: .touchUpInside)
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }
    
    func setupFullnameLabel() {
        contentView.addSubview(fullNameLabel)
    }
    
    func setupPhotoCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = Layout.photoSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        photoCollectionView?.showsHorizontalScrollIndicator = false
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self
        photoCollectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
        contentView.addSubview(photoCollectionView!)
    }

    @objc func showMoreButtonTapped() {
        guard let rewiewId = config?.id else { return }
        delegate?.didTapShowMore(for: rewiewId)
     }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    fileprivate static let ratingSize = CGSize(width: 85.0, height: 16.0)

    fileprivate static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var fullNameLabelFrame = CGRect.zero
    private(set) var reviewPhotoImageViewFrame = CGRect.zero
    private(set) var photoCollectionViewFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right - Layout.avatarSize.width - avatarToUsernameSpacing

        var maxY = insets.top
        // Координата с которой начинается расположение всех элементов кроме аватара
        let currentXPoint = insets.left + avatarImageViewFrame.width + avatarToUsernameSpacing
        
        var showShowMoreButton = false
        
        avatarImageViewFrame = CGRect(
            origin: CGPoint(x: insets.left, y: maxY),
            size: Layout.avatarSize
        )
        
        fullNameLabelFrame = CGRect(
            origin: CGPoint(x: currentXPoint, y: maxY),
            size: config.fullName.boundingRect(
                width: width,
                height: config.fullName.font()?.lineHeight ?? .zero).size)
        
        maxY = fullNameLabelFrame.maxY + usernameToRatingSpacing
        
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: currentXPoint, y: maxY),
            size: Layout.ratingSize
        )
        
        
        if let photos = config.photos {
            maxY = ratingImageViewFrame.maxY + ratingToPhotosSpacing
            if !photos.isEmpty {
                photoCollectionViewFrame = CGRect(origin: CGPoint(x: currentXPoint, y: maxY), size: CGSize(width: 330, height: 80))
                maxY = photoCollectionViewFrame.maxY + photosToTextSpacing
                
            }
        } else {
                maxY = ratingImageViewFrame.maxY + ratingToTextSpacing
        }
        
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: currentXPoint, y: maxY ),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: currentXPoint, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: currentXPoint, y: maxY),
            size: config.created.boundingRect(width: width).size
        )
        
        return createdLabelFrame.maxY + insets.bottom
    }
}

extension ReviewCell: UICollectionViewDelegate {

}

extension ReviewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        config?.photos?.count ?? 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: config?.photos?[indexPath.row] ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotoUrl = config?.photos?[indexPath.item]
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return }
        delegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
        
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout



@available(iOS 17.0, *)
#Preview {
    let factory = ReviewsScreenFactory()
    let controller = factory.makeReviewsController()
    return controller
}
