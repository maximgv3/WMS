nonisolated enum ReturnsRoute: Hashable {
    case containers(ReturnsTask)
    case task(ReturnsTask, ReturnsContainers)
    case finish(ReturnsResult)
}
