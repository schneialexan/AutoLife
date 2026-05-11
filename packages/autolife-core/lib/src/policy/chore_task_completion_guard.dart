import '../common/failure.dart';
import '../common/result.dart';
import 'capability_grant_defaults.dart';

/// Sample choke point for chores / allowance integrations (phase 3 modules call this guard).
abstract final class ChoreTaskCompletionGuard {
  static Result<void> verifyAgainstGrant({
    required CapabilityGrantDefaults grant,
    required bool photoProofUploaded,
    required bool parentMarkedVerified,
  }) {
    if (!grant.granted) {
      return Result.failure(const Failure(code: 'chores_capability_denied'));
    }
    if (grant.requirePhotoProof && !photoProofUploaded) {
      return Result.failure(const Failure(code: 'chores_photo_proof_required'));
    }
    if (grant.requireParentVerification && !parentMarkedVerified) {
      return Result.failure(
        const Failure(code: 'chores_parent_verification_required'),
      );
    }
    return const Result.success(null);
  }
}
