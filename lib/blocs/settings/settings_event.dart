import 'package:kadu_booking_app/blocs/settings/settings_bloc.dart';

abstract class SettingsEvent {}

class SettingsSelected extends SettingsEvent {
  final Setting selectedSetting;
  SettingsSelected({required this.selectedSetting});
}
