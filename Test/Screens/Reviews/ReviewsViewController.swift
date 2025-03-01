import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let refreshControl = UIRefreshControl()
    private var customSpinner = CustomSpinner()
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
        configureCustomSpinner()
        viewModel.delegate = self
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
        viewModel.onStateChange = { [weak reviewsView, unowned self] _ in
            reviewsView?.tableView.reloadData()
            customSpinner.stopAnimation()
        }
    }

    func configureRefreshControl() {
        reviewsView.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlUsed), for: .valueChanged)
    }
    
    func configureCustomSpinner() {
        customSpinner = CustomSpinner(squareLength: 50)
        reviewsView.addSubview(customSpinner)
        customSpinner.startAnimation(delay: 0.04, replicates: 20)
    }

    @objc func refreshControlUsed() {
        viewModel.refreshData()
        reviewsView.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

extension ReviewsViewController: ReviewsViewModelDelegate {
    func didTapOnCell(with photoUrl: String) {
        let vc = PhotoViewController()
        vc.photoUrl = photoUrl
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
