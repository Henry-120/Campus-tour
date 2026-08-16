/* eslint-disable no-console */
const {applicationDefault, initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');

const email = process.argv[2];
const enabledArgument = process.argv[3] ?? 'true';

initializeApp({
  credential: applicationDefault(),
  projectId: 'campus-tour-679e9',
});

async function main() {
  if (!email || !email.includes('@')) {
    throw new Error(
      'Usage: node scripts/set-reviewer-claim.js <email> [true|false]',
    );
  }
  if (!['true', 'false'].includes(enabledArgument)) {
    throw new Error('The second argument must be true or false.');
  }

  const auth = getAuth();
  const user = await auth.getUserByEmail(email);
  const existingClaims = user.customClaims ?? {};
  const enabled = enabledArgument === 'true';
  const customClaims = {...existingClaims};

  if (enabled) {
    customClaims.appReviewer = true;
    await auth.updateUser(user.uid, {emailVerified: true});
  } else {
    delete customClaims.appReviewer;
  }

  await auth.setCustomUserClaims(user.uid, customClaims);
  await auth.revokeRefreshTokens(user.uid);
  console.log(
    `${enabled ? 'Granted' : 'Revoked'} appReviewer for ${email} (${user.uid}).`,
  );
  if (enabled) console.log('Email verification status set to verified.');
  console.log('The account must sign in again before the change takes effect.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
