//Deprecated

// import 'package:flutter/foundation.dart';

// class SavedPropertiesProvider extends ChangeNotifier {
//   Map<String, int> savedProperties = {};

//   bool isPropertySaved(String propertyId, int socialSecurity) {
//     return savedProperties.containsKey(propertyId) &&
//         savedProperties[propertyId] == socialSecurity;
//   }

//   void toggleSavedProperty(String propertyId, int socialSecurity) {
//     if (isPropertySaved(propertyId, socialSecurity)) {
//       savedProperties.remove(propertyId);
//       if (kDebugMode) {
//         print('Property $propertyId removed from saved properties.');
//       }
//     } else {
//       savedProperties[propertyId] = socialSecurity;
//       if (kDebugMode) {
//         print(
//             'Property $propertyId added to saved properties for user $socialSecurity.');
//       }
//     }
//     notifyListeners();
//   }

//   List<String> getSavedPropertyIds(int socialSecurity) {
//     return savedProperties.entries
//         .where((entry) => entry.value == socialSecurity)
//         .map((entry) => entry.key)
//         .toList();
//   }
// }
