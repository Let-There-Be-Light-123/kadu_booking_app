import 'package:kadu_booking_app/blocs/settings/settings_bloc.dart';

abstract class SettingsState {
  final Setting selectedSetting;

  SettingsState({required this.selectedSetting});
}

class SettingPageInitial extends SettingsState {
  SettingPageInitial({required super.selectedSetting});
}
