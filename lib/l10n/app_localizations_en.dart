// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get validate => 'Confirm';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get services => 'Services';

  @override
  String get service_sales_cars => 'Sales (Cars)';

  @override
  String get service_delivery_parts => 'Delivery (Parts)';

  @override
  String get service_tricycle => 'Tricycle';

  @override
  String get tricycle_location_required =>
      'Please enable location to use the Tricycle service.';

  @override
  String get tricycle_permission_denied => 'Location permission denied.';

  @override
  String get tricycle_permission_denied_forever =>
      'Location permission blocked. Enable it in settings.';

  @override
  String get tricycle_position_active_title => 'Location active';

  @override
  String get tricycle_position_active_subtitle =>
      'Location is running… Nearby tricycles will refresh automatically.';

  @override
  String get tricycle_none_nearby => 'No nearby tricycles at the moment.';

  @override
  String get tricycle_out_of_range => 'Out of range';

  @override
  String get retry => 'Retry';

  @override
  String get enable_location => 'Enable location';

  @override
  String get open_settings => 'Open settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get call => 'Call';

  @override
  String get message => 'Message';

  @override
  String get tricycle_auth_required => 'Authentication required';

  @override
  String get tricycle_connect_to_see => 'Connect to see';

  @override
  String get tricycle_connect_description =>
      'Please connect your account to view this content';

  @override
  String get tricycle_home_title => 'Tricycles';
}
