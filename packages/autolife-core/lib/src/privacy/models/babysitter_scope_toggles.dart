/// Owner-selected resource toggles stored on [babysitter_links].
class BabysitterScopeToggles {
  const BabysitterScopeToggles({
    this.wifiCredentials = false,
    this.emergencyContacts = false,
    this.allergies = false,
    this.locations = false,
  });

  final bool wifiCredentials;
  final bool emergencyContacts;
  final bool allergies;
  final bool locations;

  Map<String, dynamic> toInsertRow() => {
    'wifi_credentials': wifiCredentials,
    'emergency_contacts': emergencyContacts,
    'allergies': allergies,
    'locations': locations,
  };

  BabysitterScopeToggles copyWith({
    bool? wifiCredentials,
    bool? emergencyContacts,
    bool? allergies,
    bool? locations,
  }) => BabysitterScopeToggles(
    wifiCredentials: wifiCredentials ?? this.wifiCredentials,
    emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    allergies: allergies ?? this.allergies,
    locations: locations ?? this.locations,
  );
}
