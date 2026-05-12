import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFamilyMemberSelectionKey = 'phase31.dashboard.member_filter';

class SelectedHouseholdMember extends StateNotifier<String?> {
  SelectedHouseholdMember() : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kFamilyMemberSelectionKey);
  }

  Future<void> setSelection(String? profileId) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileId == null || profileId.isEmpty) {
      await prefs.remove(_kFamilyMemberSelectionKey);
      state = null;
      return;
    }
    await prefs.setString(_kFamilyMemberSelectionKey, profileId);
    state = profileId;
  }
}

final selectedHouseholdMemberIdProvider =
    StateNotifierProvider<SelectedHouseholdMember, String?>((ref) {
  return SelectedHouseholdMember();
});
