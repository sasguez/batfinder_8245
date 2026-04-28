import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "*",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  try {
    const { event_id, user_id, latitude, longitude } = await req.json();

    const TWILIO_SID         = Deno.env.get("TWILIO_ACCOUNT_SID")!;
    const TWILIO_TOKEN       = Deno.env.get("TWILIO_AUTH_TOKEN")!;
    const TWILIO_WA_FROM     = Deno.env.get("TWILIO_WHATSAPP_FROM")!;
    const TWILIO_CONTENT_SID = Deno.env.get("TWILIO_CONTENT_SID") ?? "";
    const FCM_PROJECT_ID  = Deno.env.get("FCM_PROJECT_ID")!;
    const FCM_CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL")!;
    const FCM_PRIVATE_KEY = Deno.env.get("FCM_PRIVATE_KEY")!;
    const SB_URL          = Deno.env.get("SUPABASE_URL")!;
    const SB_KEY          = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const sb = createClient(SB_URL, SB_KEY);

    const [contactsResult, profileResult] = await Promise.all([
      sb.from("emergency_contacts")
        .select("*")
        .eq("user_id", user_id)
        .order("priority"),
      sb.from("users")
        .select("full_name")
        .eq("id", user_id)
        .maybeSingle(),
    ]);

    const contacts = contactsResult.data ?? [];
    const fullName = profileResult.data?.full_name ?? "Usuario";
    const mapsUrl  = `https://maps.google.com/?q=${latitude},${longitude}`;
    const address  = await reverseGeocode(latitude, longitude);

    console.log(`[orchestrator] contacts found: ${contacts.length}`);
    console.log(`[orchestrator] contacts detail:`, JSON.stringify(
      contacts.map((c: Record<string, unknown>) => ({
        name: c.name,
        phone_wa: c.phone_wa,
        whatsapp_optin: c.whatsapp_optin,
        has_app: c.has_app,
        fcm_token: c.fcm_token ? "SET" : "NULL",
      }))
    ));
    console.log(`[orchestrator] TWILIO_WA_FROM: ${Deno.env.get("TWILIO_WHATSAPP_FROM")}`);
    console.log(`[orchestrator] TWILIO_SID starts with: ${TWILIO_SID?.substring(0, 6)}`);

    const waMessage =
      `🚨 *ALERTA DE PÁNICO — BatFinder*\n\n` +
      `*${fullName}* necesita ayuda urgente.\n\n` +
      `📍 Ubicación en tiempo real:\n${mapsUrl}\n\n` +
      `Responde *OK* para confirmar que recibiste esta alerta.`;

    const hasAppContacts = contacts.some((c: Record<string, unknown>) => c.has_app && c.fcm_token);
    let fcmAccessToken: string | null = null;
    if (hasAppContacts) {
      fcmAccessToken = await getFCMAccessToken(FCM_CLIENT_EMAIL, FCM_PRIVATE_KEY);
    }

    await Promise.allSettled(
      contacts.map(async (c: Record<string, unknown>) => {
        if (c.has_app && c.fcm_token && fcmAccessToken) {
          await sendFCMv1(c, event_id, fullName, latitude, longitude, FCM_PROJECT_ID, fcmAccessToken, sb);
        }
        if (c.phone_wa && c.whatsapp_optin) {
          console.log(`[orchestrator] sending WhatsApp to: ${c.phone_wa}`);
          await sendWhatsApp(c, event_id, fullName, mapsUrl, address, TWILIO_SID, TWILIO_TOKEN, TWILIO_WA_FROM, TWILIO_CONTENT_SID, sb);
        } else {
          console.log(`[orchestrator] skipping WhatsApp for ${c.name}: phone_wa=${c.phone_wa}, optin=${c.whatsapp_optin}`);
        }
      })
    );

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json", ...CORS },
    });
  } catch (error) {
    return new Response(JSON.stringify({ ok: false, error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...CORS },
    });
  }
});

// ── FCM v1: OAuth2 con cuenta de servicio ─────────────────────────────────────

async function getFCMAccessToken(clientEmail: string, privateKeyPem: string): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const header  = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss:   clientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud:   "https://oauth2.googleapis.com/token",
    iat:   now,
    exp:   now + 3600,
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const signingInput = `${encode(header)}.${encode(payload)}`;

  // Limpia el PEM y lo convierte a ArrayBuffer
  const pemBody = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const derBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    derBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const jwt = `${signingInput}.${sigB64}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenRes.json();
  if (!tokenData.access_token) {
    throw new Error(`OAuth2 token error: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token as string;
}

async function sendFCMv1(
  contact: Record<string, unknown>,
  eventId: string,
  fullName: string,
  lat: number,
  lng: number,
  projectId: string,
  accessToken: string,
  sb: ReturnType<typeof createClient>,
) {
  try {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: contact.fcm_token as string,
            notification: {
              title: "🚨 ALERTA DE PÁNICO",
              body:  `${fullName} necesita ayuda urgente`,
            },
            data: {
              type:      "PANIC_ALERT",
              event_id:  eventId,
              latitude:  String(lat),
              longitude: String(lng),
              maps_url:  `https://maps.google.com/?q=${lat},${lng}`,
            },
            android: {
              priority: "high",
              notification: { sound: "default" },
            },
          },
        }),
      },
    );

    const result = await res.json();
    const success = res.ok && result.name;

    await sb.from("notification_delivery_logs").insert({
      event_id:        eventId,
      contact_id:      contact.id,
      channel:         "fcm",
      status:          success ? "sent" : "failed",
      external_sid:    success ? (result.name as string).split("/").pop() ?? null : null,
      attempts:        1,
      last_attempt_at: new Date().toISOString(),
      error_message:   success ? null : JSON.stringify(result.error ?? result),
    });
  } catch (e) {
    console.error("FCM v1 send error:", e);
  }
}

// ── Geocodificación inversa (OpenStreetMap Nominatim) ─────────────────────────

async function reverseGeocode(lat: number, lng: number): Promise<string> {
  try {
    const res = await fetch(
      `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&accept-language=es`,
      { headers: { "User-Agent": "BatFinder/1.0 (emergency-alert)" } },
    );
    if (!res.ok) return "";
    const data = await res.json();
    const a = data.address ?? {};
    const city = (a.city ?? a.town ?? a.municipality ?? "").replace(/\s+ciudad$/i, "");
    const parts = [
      a.neighbourhood ?? a.suburb ?? a.quarter ?? a.village ?? "",
      city,
      a.state ?? "",
    ].filter(Boolean);
    return parts.join(", ");
  } catch {
    return "";
  }
}

// ── Twilio WhatsApp ───────────────────────────────────────────────────────────

async function sendWhatsApp(
  contact: Record<string, unknown>,
  eventId: string,
  fullName: string,
  mapsUrl: string,
  address: string,
  sid: string,
  token: string,
  from: string,
  contentSid: string,
  sb: ReturnType<typeof createClient>,
) {
  try {
    const rawPhone = (contact.phone_wa as string).replace(/\s/g, "");
    const toPhone  = rawPhone.startsWith("+") ? rawPhone : `+${rawPhone}`;
    const toWA     = `whatsapp:${toPhone}`;

    console.log(`[sendWhatsApp] From: ${from} | To: ${toWA} | contentSid: ${contentSid || "none"} | sid_prefix: ${sid?.substring(0, 8)}`);

    const credentials = btoa(`${sid}:${token}`);

    const locationLine = address
      ? `📍 ${address}\n🗺️ Ver en mapa: ${mapsUrl}`
      : `📍 Ver en mapa: ${mapsUrl}`;

    const params: Record<string, string> = { From: from, To: toWA };
    if (contentSid) {
      params["ContentSid"] = contentSid;
      params["ContentVariables"] = JSON.stringify({ "1": fullName, "2": address || mapsUrl, "3": mapsUrl });
    } else {
      params["Body"] =
        `🚨 ALERTA DE PÁNICO — BatFinder\n\n` +
        `*${fullName}* necesita ayuda urgente.\n\n` +
        `${locationLine}\n\n` +
        `Responde OK para confirmar.`;
    }

    const bodyStr = new URLSearchParams(params).toString();
    console.log(`[sendWhatsApp] request body: ${bodyStr}`);

    const res = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`,
      {
        method: "POST",
        headers: {
          Authorization: `Basic ${credentials}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: bodyStr,
      },
    );

    const result = await res.json();
    console.log(`[sendWhatsApp] HTTP ${res.status} | full_response: ${JSON.stringify(result)}`);

    const success = res.ok && (result.status === "queued" || result.status === "sent" || result.status === "accepted");
    await sb.from("notification_delivery_logs").insert({
      event_id:        eventId,
      contact_id:      contact.id,
      channel:         "whatsapp",
      status:          success ? "sent" : "failed",
      external_sid:    result.sid ?? null,
      attempts:        1,
      last_attempt_at: new Date().toISOString(),
      error_message:   success ? null : (result.message ?? result.error_message ?? JSON.stringify(result)),
    });
  } catch (e) {
    console.error("[sendWhatsApp] exception:", e);
  }
}
