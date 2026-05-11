import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('blocks when photo proof missing', () {
    const grant = CapabilityGrantDefaults(
      granted: true,
      requiresParentApproval: false,
      requirePhotoProof: true,
      requireParentVerification: false,
    );
    final r = ChoreTaskCompletionGuard.verifyAgainstGrant(
      grant: grant,
      photoProofUploaded: false,
      parentMarkedVerified: true,
    );
    expect(r.when(success: (_) => false, failure: (_) => true), isTrue);
    expect(
      r.when(success: (_) => null, failure: (f) => f.code),
      'chores_photo_proof_required',
    );
  });

  test('blocks when parent verification missing', () {
    const grant = CapabilityGrantDefaults(
      granted: true,
      requiresParentApproval: false,
      requirePhotoProof: false,
      requireParentVerification: true,
    );
    final r = ChoreTaskCompletionGuard.verifyAgainstGrant(
      grant: grant,
      photoProofUploaded: true,
      parentMarkedVerified: false,
    );
    expect(r.when(success: (_) => false, failure: (_) => true), isTrue);
    expect(
      r.when(success: (_) => null, failure: (f) => f.code),
      'chores_parent_verification_required',
    );
  });

  test('passes when enforcement satisfied', () {
    const grant = CapabilityGrantDefaults(
      granted: true,
      requiresParentApproval: false,
      requirePhotoProof: true,
      requireParentVerification: true,
    );
    final r = ChoreTaskCompletionGuard.verifyAgainstGrant(
      grant: grant,
      photoProofUploaded: true,
      parentMarkedVerified: true,
    );
    expect(r.when(success: (_) => true, failure: (_) => false), isTrue);
  });
}
