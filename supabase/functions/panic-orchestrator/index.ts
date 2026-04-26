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

    const TWILIO_SID     = Deno.env.get("TWILIO_ACCOUNT_SID")!;
    const TWILIO_TOKEN   = Deno.env.get("TWILIO_AUTH_TOKEN")!;
    const TWILIO_WA_FROM = Deno.env.get("TWILIO_WHATSAPP_FROM")!;
    const FCM_KEY        = Deno.env.get("FCM_SERVER_KEY")!;
    const SB_URL         = Deno.env.get("SUPABASE_URL")!;
    const SB_KEY         = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

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

    const waMessage =
      `🚨 *ALERTA DE PÁNICO — BatFinder*\n\n` +
      `*${fullName}* necesita ayuda urgente.\n\n` +
      `📍 Ubicación en tiempo real:\n${mapsUrl}\n\n` +
      `Responde *OK* para confirmar que recibiste esta alerta.`;

    await Promise.allSettled(
      contacts.map(async (c: Record<string, unknown>) => {
        if (c.has_app && c.fcm_token) {
          await sendFCM(c, event_id, fullName, latitude, longitude, FCM_KEY, sb);
        }
        if (c.phone_wa && c.whatsapp_optin) {
          await sendWhatsApp(c, event_id, waMessage, TWILIO_SID, TWILIO_TOKEN, TWILIO_WA_FROM, sb);
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

async function sendFCM(
  contact: Record<string, unknown>,
  eventId: string,
  fullName: string,
  lat: number,
  lng: number,
  fcmKey: string,
  sb: ReturnType<typeof createClient>,
) {
  try {
    const res = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        Authorization: `key=${fcmKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        to: contact.fcm_token,
        priority: "high",
        notification: {
          title: "🚨 ALERTA DE PÁNICO",
          body: `${fullName} necesita ayuda urgente`,
        },
        data: {
          type: "PANIC_ALERT",
          event_id: eventId,
          latitude: String(lat),
          longitude: String(lng),
          maps_url: `https://maps.google.com/?q=${lat},${lng}`,
        },
      }),
    });
    const result = await res.json();
    await sb.from("notification_delivery_logs").insert({
      event_id:        eventId,
      contact_id:      contact.id,
      channel:         "fcm",
      status:          result.success === 1 ? "sent" : "failed",
      external_sid:    result.results?.[0]?.message_id ?? null,
      attempts:        1,
      last_attempt_at: new Date().toISOString(),
      error_message:   result.results?.[0]?.error ?? null,
    });
  } catch (e) {
    console.error("FCM send error:", e);
  }
}

async function sendWhatsApp(
  contact: Record<string, unknown>,
  eventId: string,
  message: string,
  sid: string,
  token: string,
  from: string,
  sb: ReturnType<typeof createClient>,
) {
  try {
    const credentials = btoa(`${sid}:${token}`);
    const res = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`,
      {
        method: "POST",
        headers: {
          Authorization: `Basic ${credentials}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          From: from,
          To:   `whatsapp:${contact.phone_wa as string}`,
          Body: message,
        }).toString(),
      }
    );
    const result = await res.json();
    await sb.from("notification_delivery_logs").insert({
      event_id:        eventId,
      contact_id:      contact.id,
      channel:         "whatsapp",
      status:          result.status === "queued" ? "sent" : "failed",
      external_sid:    result.sid ?? null,
      attempts:        1,
      last_attempt_at: new Date().toISOString(),
      error_message:   result.message ?? null,
    });
  } catch (e) {
    console.error("WhatsApp send error:", e);
  }
}
