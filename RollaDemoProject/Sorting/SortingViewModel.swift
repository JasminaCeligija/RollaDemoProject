import Foundation

protocol SortingViewModelType: ObservableObject {
    var selectedSortingOrder: SortingOrder { get set }
    var state: SortingViewState { get }
    var primaryButtonTitle: String { get }
    func didTapPrimaryButton()
}

final class SortingViewModel: SortingViewModelType {
    private let arrayCount: Int
    @Published var state: SortingViewState
    @Published var primaryButtonTitle = "Start"
    @Published var selectedSortingOrder: SortingOrder = .ascending
    private var sortedNumbers = [Int]()

    init() {
        arrayCount = 25000000
        state = .idle("Generate and sort \(arrayCount) numbers.")
    }

    func didTapPrimaryButton() {
        let startTime = startSorting()
        let randomNumbers = generateRandomNumbers(arrayCount)
        Task {
            sortedNumbers = await parallelMergeSort(randomNumbers, isAscending: selectedSortingOrder.isAscending)
            await MainActor.run {
                finishSorting(startTime: startTime)
            }
        }
    }

    private func startSorting() -> DispatchTime {
        self.state = .sorting
        return DispatchTime.now()
    }

    private func finishSorting(startTime: DispatchTime) {
        let endTime = DispatchTime.now()
        let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        self.state = .sorted("Time taken to sort numbers: \(elapsedTime) seconds")
    }

    func generateRandomNumbers( _ count: Int) -> [Int] {
        var randomNumbers = [Int](repeating: 0, count: count)
        randomNumbers.withUnsafeMutableBufferPointer { buffer in
            arc4random_buf(buffer.baseAddress, buffer.count * MemoryLayout<Int>.stride)
        }
        return randomNumbers
    }

    func parallelMergeSort(_ array: [Int], isAscending: Bool = true, threshold: Int = 900000) async -> [Int] {
        return await parallelMergeSort(array, start: 0, end: array.count - 1, isAscending: isAscending, threshold: threshold)
    }

    func parallelMergeSort(_ array: [Int], start: Int, end: Int, isAscending: Bool = true, threshold: Int) async -> [Int] {
        if end - start + 1 <= threshold {
            var resultArray = Array(array[start...end])
            timsort(&resultArray, isAscending: isAscending)
            return resultArray
        }

        let mid = (start + end) / 2
        let leftResult = Task.detached {
            await self.parallelMergeSort(array, start: start, end: mid, isAscending: isAscending, threshold: threshold)
        }

        let rightResult = Task.detached {
            await self.parallelMergeSort(array, start: mid + 1, end: end, isAscending: isAscending, threshold: threshold)
        }
        var left = await leftResult.value
        var right = await rightResult.value
        return merge(&left, &right, isAscending: isAscending)
    }

    func merge(_ left: inout [Int], _ right: inout [Int], isAscending: Bool = true) -> [Int] {
        var mergedArray: [Int] = []
        mergedArray.reserveCapacity(left.count + right.count)
        var leftIndex = 0
        var rightIndex = 0

        while leftIndex < left.count && rightIndex < right.count {
            if (isAscending && left[leftIndex] < right[rightIndex]) || (!isAscending && left[leftIndex] > right[rightIndex]) {
                mergedArray.append(left[leftIndex])
                leftIndex += 1
            } else {
                mergedArray.append(right[rightIndex])
                rightIndex += 1
            }
        }

        while leftIndex < left.count {
            mergedArray.append(left[leftIndex])
            leftIndex += 1
        }

        while rightIndex < right.count {
            mergedArray.append(right[rightIndex])
            rightIndex += 1
        }

        return mergedArray
    }
}

extension SortingViewModel {
    func insertionSort(_ array: inout [Int], _ start: Int, _ end: Int, _ isAscending: Bool) {
        for i in start + 1 ... end {
            var j = i
            let currentElement = array[i]

            while j > start && (isAscending ? currentElement < array[j - 1] : currentElement > array[j - 1]) {
                array[j] = array[j - 1]
                j -= 1
            }

            array[j] = currentElement
        }
    }

    func mergeTim(_ array: inout [Int], _ left: Int, _ mid: Int, _ right: Int, _ isAscending: Bool) {
        let n1 = mid - left + 1
        let n2 = right - mid

        let leftArray = Array(array[left ..< (left + n1)])
        let rightArray = Array(array[(mid + 1) ..< (mid + 1 + n2)])

        var i = 0, j = 0, k = left
        while i < n1 && j < n2 {
            if (isAscending ? leftArray[i] <= rightArray[j] : leftArray[i] >= rightArray[j]) {
                array[k] = leftArray[i]
                i += 1
            } else {
                array[k] = rightArray[j]
                j += 1
            }
            k += 1
        }

        while i < n1 {
            array[k] = leftArray[i]
            i += 1
            k += 1
        }

        while j < n2 {
            array[k] = rightArray[j]
            j += 1
            k += 1
        }
    }

    func timsort(_ array: inout [Int], isAscending: Bool) {
        let minRun = 16
        let n = array.count

        for i in stride(from: 0, to: n, by: minRun) {
            let insertionEnd = Swift.min(i + minRun - 1, n - 1)
            insertionSort(&array, i, insertionEnd, isAscending)
        }

        var size = minRun
        while size < n {
            for left in stride(from: 0, to: n, by: size * 2) {
                let mid = Swift.min(left + size - 1, n - 1)
                let right = Swift.min(left + size * 2 - 1, n - 1)
                mergeTim(&array, left, mid, right, isAscending)
            }
            size *= 2
        }
    }
}

enum SortingViewState: Equatable {
    case idle(String)
    case sorting
    case sorted(String)
}

enum SortingOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"

    var isAscending: Bool {
        return self == .ascending
    }
}
