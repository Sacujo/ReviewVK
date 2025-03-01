import UIKit

protocol ReviewsViewModelDelegate: AnyObject {
    func didTapOnCell(with photoUrl: String)
}
/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    weak var delegate: ReviewsViewModelDelegate?
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset, completion: gotReviews)
    }
    ///  Метод для обновления данных
    func refreshData() {
        state.items.removeAll()
        state.offset = 0
        state.shouldLoad = true
        getReviews()
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.totalItemsCount = reviews.count
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
            onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }
    

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let avatar = review.avatar
        let rating = review.rating
        let photosURL = review.photosURL?.map { $0.url }
        let fullName = review.fullName.attributed(font: .username)
        let item = ReviewItem(
            reviewText: reviewText,
            rating: rating,
            avatar: avatar,
            fullName: fullName,
            photos: photosURL,
            created: created,
            onTapShowMore: showMoreReview
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath) as! ReviewCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = ReviewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        footerView.configure(with: state.totalItemsCount ?? 0)
        return footerView
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let config = state.items[indexPath.row]
        config.update(cell: cell)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}

//MARK: - ReviewCellDelegate

extension ReviewsViewModel: ReviewCellDelegate {
    func didTapShowMore(for rewiewId: UUID) {
        showMoreReview(with: rewiewId)
    }
    
    func collectionView(collectionviewcell: PhotoCell?, index: Int, didTappedInTableViewCell: ReviewCell) {
        if let photoUrl = didTappedInTableViewCell.selectedPhotoUrl {
            delegate?.didTapOnCell(with: photoUrl)
        }
    }
}
