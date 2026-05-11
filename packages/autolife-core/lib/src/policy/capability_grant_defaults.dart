/// Default cell from [policy/matrix.yaml] (shared by codegen + services).
class CapabilityGrantDefaults {
  const CapabilityGrantDefaults({
    required this.granted,
    required this.requiresParentApproval,
    required this.requirePhotoProof,
    required this.requireParentVerification,
  });

  final bool granted;
  final bool requiresParentApproval;
  final bool requirePhotoProof;
  final bool requireParentVerification;
}
