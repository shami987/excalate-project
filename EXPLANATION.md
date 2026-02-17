# Bug Explanation

## What was the bug?

The HttpClient.request method failed to refresh expired OAuth2 tokens when they were stored as plain objects instead of OAuth2Token instances. When `oauth2Token` was a plain object like `{ accessToken: "stale", expiresAt: 0 }`, no Authorization header was set, even though the token was expired.

## Why did it happen?

The original condition used `instanceof OAuth2Token` to check expiration:

```typescript
if (
  !this.oauth2Token ||
  (this.oauth2Token instanceof OAuth2Token && this.oauth2Token.expired)
)
```

When `oauth2Token` was a plain object, `instanceof OAuth2Token` returned false, so the expiration check never ran. The token wasn't refreshed, and since it wasn't an OAuth2Token instance, no Authorization header was added.

## Why does your fix solve it?

The fix extracts expiration logic to handle both types:

```typescript
const isExpired = this.oauth2Token instanceof OAuth2Token
  ? this.oauth2Token.expired
  : typeof this.oauth2Token === "object" && this.oauth2Token !== null
  ? Date.now() / 1000 >= (this.oauth2Token.expiresAt as number)
  : false;
```

Now plain objects are checked for expiration by comparing `Date.now() / 1000` with their `expiresAt` property, matching the OAuth2Token.expired logic.

## One realistic case / edge case your tests still don't cover

The tests don't cover the case where a plain object token has a missing or invalid `expiresAt` property (e.g., `{ accessToken: "token" }` without `expiresAt`, or `expiresAt: "invalid"`). The current fix would fail or behave unexpectedly with malformed token objects.
