const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { getFirestore } = require("firebase-admin/firestore");
const axios = require("axios");
const crypto = require("crypto");

// 店舗ごとの電話番号（SMS本文と確認ページで共用）
const BRANCH_PHONES = { '岡崎本店': '0564-23-8861', '名古屋店': '050-1748-2670', '岐阜店': '050-1748-2670' };
const DEFAULT_PHONE = '0564-23-8861';
const REPLY_BASE_URL = "https://katura-system-app.web.app/r";

if (admin.apps.length === 0) { admin.initializeApp(); }
setGlobalOptions({ region: "us-central1" });

/**
 * 毎日1分ごとに起動し、店舗設定の「送信時刻」になったら一括送信する
 */
exports.orderAutoSms = onSchedule("every 1 minutes", async (event) => {
  const db = getFirestore("katura-system-database");
  const now = new Date();

  // 1. 日本時間の現在時刻を取得 (HH:mm)
  const jstNow = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const currentJstTime = `${jstNow.getUTCHours().toString().padStart(2, '0')}:${jstNow.getUTCMinutes().toString().padStart(2, '0')}`;

  console.log(`[V2 SMS Job] Heartbeat. Current JST: ${currentJstTime}`);

  try {
    // 2. 店舗全体の送信設定（時間）を読み込む
    const configDoc = await db.collection("settings").doc("sms_config").get();
    const globalSendingTime = configDoc.exists ? configDoc.data().sendingTime : "09:00";

    // 3. 設定時刻と一致しない場合は何もしない
    if (currentJstTime !== globalSendingTime) {
      return;
    }

    console.log(`[V2 SMS Job] Matching Time! Starting bulk send for Tomorrow's orders.`);

    // 4. 「明日」の日付文字列を作成 (yyyy-MM-dd)
    const tomorrow = new Date(jstNow.getTime() + 24 * 60 * 60 * 1000);
    const tomorrowStr = tomorrow.toISOString().split('T')[0];

    // 5. 明日配達予定 且つ 未送信 の注文を検索 (MethodをSMSに修正)
    const snapshot = await db.collection("orders")
      .where("deliveryDateStr", "==", tomorrowStr)
      .where("smsSent", "==", false)
      .where("preConfirmationMethod", "==", "SMS")
      .get();

    if (snapshot.empty) {
      console.log(`[V2 SMS Job] No orders found for delivery date: ${tomorrowStr}`);
      return;
    }

    console.log(`[V2 SMS Job] Found ${snapshot.size} orders. Sending now...`);

    for (const doc of snapshot.docs) {
      const order = doc.data();
      const rawPhone = order.phoneNumber || order.phoneDisplay || "";
      const cleanPhone = rawPhone.replace(/[^0-9]/g, "");

      if (!cleanPhone) continue;

      const internationalPhone = cleanPhone.startsWith("0") ? "81" + cleanPhone.substring(1) : cleanPhone;
      const message = buildSmsMessage(order);

      try {
        const response = await axios.post("https://rest.nexmo.com/sms/json", {
          api_key: "14caff28",
          api_secret: "FumC5ojafuwOcWXK",
          from: "Katura",
          to: internationalPhone,
          text: message,
          type: "unicode"
        });

        if (response.data.messages[0].status === "0") {
          await doc.ref.update({ smsSent: true, smsSentAt: admin.firestore.FieldValue.serverTimestamp() });
          console.log(`[V2 Success] Sent to ${order.customerName}`);
        }
      } catch (e) {
        console.error(`[V2 Error] Failed to send to ${order.customerName}: ${e.message}`);
      }
    }
  } catch (error) {
    console.error("[V2 Fatal Error]", error.message);
  }
});

function buildSmsMessage(order) {
  const deliveryDate = new Date(order.deliveryDate);
  const dateStr = `${deliveryDate.getMonth() + 1}月${deliveryDate.getDate()}日`;
  const weekDays = ["日", "月", "火", "水", "木", "金", "土"];
  const weekDay = weekDays[deliveryDate.getDay()];
  let itemsText = "";
  if (Array.isArray(order.items)) {
    order.items.forEach((item, index) => {
      itemsText += `${index + 1}.${item.name || item['name']} x${item.quantity || item['quantity']}\n`;
    });
  }
  let trashInfo = "なし";
  if (order.trashPickupDateTime) {
    const trashDate = new Date(order.trashPickupDateTime);
    const jstHours = (trashDate.getUTCHours() + 9) % 24;
    trashInfo = `${jstHours}:${trashDate.getUTCMinutes().toString().padStart(2, '0')}`;
  }
  const isPickup = order.deliveryType === '引取' || order.deliveryType === '店頭引取';
  const storePhone = BRANCH_PHONES[order.branchName] || DEFAULT_PHONE;

  return `「肉弁当専門店かつらです」\n${order.customerName}様\nこの度はご注文ありがとうございます。\n下記内容にて明日${dateStr}${weekDay}曜日 ${order.deliveryTime}に${isPickup ? "お待ちしております" : "お届けいたします"}。\n\n受取人：${order.receiverName || order.customerName}様\n${isPickup ? '引取店舗' : '配達先住所'}：${order.address}\n連絡先：${order.phoneNumber || order.phoneDisplay}\n\nー注文内容ー\n${itemsText}\nーお支払い金額ー\n${order.totalPrice}円（税込）\n\n容器回収日時：${trashInfo}\n回収場所：${order.trashPickupLocationDetail || '配達場所と同じ'}\n\n内容に不備がある場合お気軽にお電話ください\n${storePhone}`;
}


/**
 * Web版用：ブラウザから直接呼べないGoogle検索API（CORS制限）を代わりに呼ぶ中継。
 * 許可するのは下記のGoogle Maps検索APIのURLだけ。
 */
const MAPS_PROXY_ALLOWED = [
  "/maps/api/place/autocomplete/json",
  "/maps/api/place/textsearch/json",
  "/maps/api/geocode/json",
];

exports.mapsProxy = onRequest({ cors: true }, async (req, res) => {
  try {
    const target = new URL(String(req.query.u || ""));
    if (target.protocol !== "https:" || target.hostname !== "maps.googleapis.com" ||
        !MAPS_PROXY_ALLOWED.includes(target.pathname)) {
      res.status(400).json({ error: "not allowed" });
      return;
    }
    const r = await axios.get(target.toString(), { validateStatus: () => true });
    res.status(r.status).json(r.data);
  } catch (e) {
    res.status(400).json({ error: "bad request" });
  }
});


/**
 * お客様の確認ページ（了承/変更/キャンセル）。GETで画面、POSTで返信を記録する。
 */
const REPLY_ACTIONS = { ok: "承認", change: "変更", cancel: "キャンセル" };

function esc(v) {
  return String(v == null ? "" : v)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}

function page(body) {
  return `<!doctype html><html lang="ja"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>ご注文の確認</title>
<style>body{font-family:sans-serif;margin:0;padding:24px 16px;text-align:center;color:#222}
h1{font-size:20px}p{font-size:16px;line-height:1.6}
button{display:block;width:100%;max-width:360px;margin:14px auto;padding:20px;font-size:20px;border:0;border-radius:12px;color:#fff;background:#2e7d32}
button.c{background:#1565c0}button.x{background:#c62828}a{color:#1565c0;font-size:20px}</style>
</head><body>${body}</body></html>`;
}

function errorPage(res, code) {
  res.status(code).set("Content-Type", "text/html; charset=utf-8")
    .send(page("<h1>ページを表示できません</h1><p>リンクをご確認のうえ、店舗へお問い合わせください。</p>"));
}

function safeEqual(a, b) {
  const ba = Buffer.from(String(a));
  const bb = Buffer.from(String(b));
  if (ba.length !== bb.length) return false;
  return crypto.timingSafeEqual(ba, bb);
}

exports.smsReply = onRequest(async (req, res) => {
  try {
    const orderId = String(req.query.o || "");
    const token = String(req.query.t || "");
    if (!orderId || !token || orderId.length > 128 || token.length > 128 || orderId.includes("/")) {
      return errorPage(res, 400);
    }
    if (req.method !== "GET" && req.method !== "POST") return errorPage(res, 400);

    const ref = getFirestore("katura-system-database").collection("orders").doc(orderId);
    const snap = await ref.get();
    const order = snap.exists ? snap.data() : null;
    if (!order || !order.replyToken || !safeEqual(order.replyToken, token)) {
      return errorPage(res, 404);
    }
    const phone = BRANCH_PHONES[order.branchName] || DEFAULT_PHONE;

    if (req.method === "GET") {
      const action = `?o=${encodeURIComponent(orderId)}&t=${encodeURIComponent(token)}`;
      return res.status(200).set("Content-Type", "text/html; charset=utf-8").send(page(
        `<h1>${esc(order.customerName)}様<br>ご注文内容のご確認</h1>
<p>内容をご確認のうえ、下のボタンを押してください。</p>
<form method="POST" action="${esc(action)}">
<button type="submit" name="action" value="ok">了承</button>
<button type="submit" name="action" value="change" class="c">変更</button>
<button type="submit" name="action" value="cancel" class="x">キャンセル</button>
</form>`));
    }

    const action = String((req.body && req.body.action) || "");
    if (!Object.prototype.hasOwnProperty.call(REPLY_ACTIONS, action)) return errorPage(res, 400);
    await ref.update({
      smsReply: REPLY_ACTIONS[action],
      smsRepliedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const msg = action === "ok"
      ? "<h1>ご確認ありがとうございました</h1>"
      : `<h1>受け付けました</h1><p>変更・キャンセルは店舗へお電話ください。</p><p><a href="tel:${esc(phone)}">${esc(phone)}</a></p>`;
    return res.status(200).set("Content-Type", "text/html; charset=utf-8").send(page(msg));
  } catch (e) {
    console.error("[smsReply Error]", e.message);
    return errorPage(res, 400);
  }
});
