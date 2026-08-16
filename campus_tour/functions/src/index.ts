import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";

initializeApp();

const recentAuthenticationWindowSeconds = 5 * 60;

function isMissingStorageBucket(error: unknown): boolean {
  if (typeof error !== "object" || error === null) return false;

  const candidate = error as {
    code?: number | string;
    message?: string;
    errors?: Array<{reason?: string}>;
  };
  return (candidate.code === 404 || candidate.code === "404") &&
    (candidate.message?.includes("bucket does not exist") === true ||
      candidate.errors?.some((item) => item.reason === "notFound") === true);
}

export const deleteMyAccount = onCall(
  {
    region: "asia-east1",
    timeoutSeconds: 540,
    memory: "1GiB",
    // Enable after App Check has been configured for every production app.
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in is required.");
    }

    const uid = request.auth.uid;
    const authTime = Number(request.auth.token.auth_time ?? 0);
    const nowSeconds = Math.floor(Date.now() / 1000);

    if (authTime <= 0 ||
        nowSeconds - authTime > recentAuthenticationWindowSeconds) {
      throw new HttpsError(
        "failed-precondition",
        "Recent authentication is required.",
      );
    }

    try {
      const firestore = getFirestore();

      // Deletes users/{uid}, every nested subcollection, and orphaned nested
      // documents under that path. Retrying this operation is safe.
      await firestore.recursiveDelete(firestore.doc(`users/${uid}`));

      // User-owned uploads must use this prefix. deleteFiles is also safe to
      // retry when no matching objects remain.
      try {
        await getStorage().bucket().deleteFiles({
          prefix: `users/${uid}/`,
          force: true,
        });
      } catch (error) {
        if (!isMissingStorageBucket(error)) throw error;
        logger.warn("Skipping account storage cleanup: bucket not found", {
          uid,
        });
      }

      // Authentication is intentionally last so a failed cleanup can be
      // retried by the still-authenticated owner.
      await getAuth().deleteUser(uid);

      logger.info("Account deletion completed", {uid});
      return {success: true};
    } catch (error) {
      logger.error("Account deletion failed", {uid, error});
      throw new HttpsError("internal", "Unable to delete account.");
    }
  },
);
