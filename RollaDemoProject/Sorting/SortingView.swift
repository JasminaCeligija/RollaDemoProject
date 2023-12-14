import SwiftUI

struct SortingView<ViewModel: SortingViewModelType>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Picker("Sorting Order", selection: $viewModel.selectedSortingOrder) {
                Text(SortingOrder.ascending.rawValue).tag(SortingOrder.ascending)
                Text(SortingOrder.descending.rawValue).tag(SortingOrder.descending)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 30)

            Spacer()

            switch viewModel.state {
            case .idle(let title):
                Text(title)
                    .customTitleStyle()
            case .sorting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.blue)
                    .scaleEffect(2.0)
            case .sorted(let elapsedTime):
                Text(elapsedTime)
                    .customTitleStyle()
            }
            Spacer()
            PrimaryButton(viewModel.primaryButtonTitle) {
                viewModel.didTapPrimaryButton()
            }
            .disabled(viewModel.state == .sorting)
        }
        .padding(25)
    }
}

#Preview {
    SortingView(viewModel: SortingViewModel())
}
