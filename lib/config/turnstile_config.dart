/// Clé publique Cloudflare Turnstile (site key).
/// Créez vos clés sur https://dash.cloudflare.com/?to=/:account/turnstile
///
/// En production, préférez --dart-define=TURNSTILE_SITE_KEY=xxx au build.
const String kTurnstileSiteKey = String.fromEnvironment(
  'TURNSTILE_SITE_KEY',
  defaultValue: '',
);

bool get isTurnstileConfigured => kTurnstileSiteKey.trim().isNotEmpty;
