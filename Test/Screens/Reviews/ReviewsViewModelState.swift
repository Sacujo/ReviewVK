/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig]()
    var limit = 30
    var offset = 0
    var shouldLoad = true
    var totalItemsCount: Int?

}
