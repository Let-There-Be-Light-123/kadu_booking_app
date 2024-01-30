import 'package:bloc/bloc.dart';
import 'package:kadu_booking_app/blocs/settings/settings_event.dart';
import 'package:kadu_booking_app/blocs/settings/settings_state.dart';

enum Setting {
  profile,
  contactUs,
  logout,
  shareApp,
  rateUs,
  aboutus,
  terms,
  privacy,
  defaultSetting
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingPageInitial(selectedSetting: Setting.privacy)) {
    on<SettingsEvent>((event, emit) {
      if (event is SettingsSelected) {
        emit(SettingPageInitial(selectedSetting: event.selectedSetting));
      }
    });
  }
}
