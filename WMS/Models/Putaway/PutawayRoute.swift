nonisolated enum PutawayRoute: Hashable {
    case container(PutawayTask)
    case task(PutawayTask)
    case finish(PutawayResult)
}
