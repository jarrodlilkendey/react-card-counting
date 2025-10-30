// lambda/index.mjs
import { SESv2Client, SendEmailCommand } from "@aws-sdk/client-sesv2";

const ses = new SESv2Client({
  region: process.env.AWS_REGION || "ap-southeast-2",
});

// Configure these via Lambda env vars
const TO_EMAIL = process.env.TO_EMAIL; // your mailbox (must be verified if in SES sandbox)
const FROM_EMAIL = process.env.FROM_EMAIL; // verified identity in SES
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS || "").split(","); // e.g. https://your.site

function corsHeaders(origin) {
  const allow = ALLOWED_ORIGINS.includes(origin) ? origin : "";
  return {
    "Access-Control-Allow-Origin": allow,
    "Access-Control-Allow-Methods": "POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Max-Age": "86400",
    // If you need cookies, also set:
    // "Access-Control-Allow-Credentials": "true"
  };
}

function isValidEmail(s) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s || "");
}

function requireFields(body, fields) {
  for (const f of fields)
    if (!body?.[f] || String(body[f]).trim() === "") return false;
  return true;
}

export const handler = async (event) => {
  const origin = event.headers?.origin || event.headers?.Origin || "";
  const baseHeaders = corsHeaders(origin);

  // Preflight
  if (event.requestContext?.http?.method === "OPTIONS") {
    return { statusCode: 204, headers: baseHeaders, body: "" };
  }

  try {
    if (event.requestContext?.http?.method !== "POST") {
      return {
        statusCode: 405,
        headers: baseHeaders,
        body: JSON.stringify({ error: "Method Not Allowed" }),
      };
    }

    const body = JSON.parse(event.body || "{}");

    // Honeypot
    if (body.website) {
      return {
        statusCode: 200,
        headers: baseHeaders,
        body: JSON.stringify({ ok: true }),
      };
    }

    if (!requireFields(body, ["name", "email", "message"])) {
      return {
        statusCode: 400,
        headers: baseHeaders,
        body: JSON.stringify({ error: "Missing required fields" }),
      };
    }
    if (!isValidEmail(body.email)) {
      return {
        statusCode: 400,
        headers: baseHeaders,
        body: JSON.stringify({ error: "Invalid email" }),
      };
    }

    // Build email
    const subject = `New contact form: ${body.name}`;
    const text = [
      `Name: ${body.name}`,
      `Email: ${body.email}`,
      body.phone ? `Phone: ${body.phone}` : null,
      `Message:\n${body.message}`,
      "",
      `IP: ${event.requestContext?.http?.sourceIp || "unknown"}`,
      `UA: ${event.headers?.["user-agent"] || "unknown"}`,
      `Time: ${new Date().toISOString()}`,
    ]
      .filter(Boolean)
      .join("\n");

    const cmd = new SendEmailCommand({
      FromEmailAddress: FROM_EMAIL,
      Destination: { ToAddresses: [TO_EMAIL] },
      Content: {
        Simple: {
          Subject: { Data: subject, Charset: "UTF-8" },
          Body: {
            Text: { Data: text, Charset: "UTF-8" },
          },
        },
      },
      ReplyToAddresses: isValidEmail(body.email) ? [body.email] : [],
    });

    await ses.send(cmd);

    return {
      statusCode: 200,
      headers: baseHeaders,
      body: JSON.stringify({ ok: true }),
    };
  } catch (err) {
    console.error("ERROR", err);
    return {
      statusCode: 500,
      headers: baseHeaders,
      body: JSON.stringify({ error: "Internal Server Error" }),
    };
  }
};
