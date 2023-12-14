import SwiftUI

struct LocationView<ViewModel: LocationViewModelType>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.formattedCurrentSpeed)
                Text(viewModel.formattedTraveledDistance)
            }
            .customTitleStyle()

            Spacer()
            PrimaryButton(viewModel.primaryButtonText) {
                viewModel.didTapPrimaryButton()
            }
        }
        .padding(25)
        .alert(item: $viewModel.authorizationAlert) { alertContent in
            return Alert(
                title: Text(alertContent.title),
                message: Text(alertContent.message),
                primaryButton: .cancel(),
                secondaryButton: .default(Text(alertContent.buttonTitle)) {
                    viewModel.didTapOpenSettingsButton()
                }
            )
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(viewModel: LocationViewModel(locationManager: LocationManager()))
    }
}
