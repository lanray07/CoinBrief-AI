enum LoadableState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        if case let .loaded(value) = self {
            return value
        }
        return nil
    }
}

