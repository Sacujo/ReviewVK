import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private var spinnerView = UIActivityIndicatorView()
    private let refreshControl = UIRefreshControl()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
        configureRefreshControl()
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak reviewsView] _ in
            reviewsView?.tableView.reloadData()
        }
    }

    func configureRefreshControl() {
        reviewsView.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlUsed), for: .valueChanged)
    }
    
    @objc func refreshControlUsed() {
        viewModel.refreshData()
        reviewsView.tableView.reloadData()
        refreshControl.endRefreshing()
    }


}
