const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { getFirestore } = require("firebase-admin/firestore");
const axios = require("axios");

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

    // 3. 設定時刻と一致しない場合は何もしない (案1の挙動)
    if (currentJstTime !== globalSendingTime) {
      return;
    }

    console.log(`[V2 SMS Job] Matching Time! Starting bulk send for Tomorrow's orders.`);

    // 4. 「明日」の日付文字列を作成 (yyyy-MM-dd)
    const tomorrow = new Date(jstNow.getTime() + 24 * 60 * 60 * 1000);
    const tomorrowStr = tomorrow.toISOString().split('T')[0];

    // 5. 明日配達予定 且つ 未送信 の注文を検索
    const snapshot = await db.collection("orders")
      .where("deliveryDateStr", "==", tomorrowStr) // 配達日(文字列)で検索
      .where("snsSent", "==", false)
      .where("preConfirmationMethod", "==", "SNS")
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
          await doc.ref.update({ snsSent: true, snsSentAt: admin.firestore.FieldValue.serverTimestamp() });
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
  const branchPhones = { '岡崎本店': '0564-23-8861', '名古屋店': '050-1748-2670', '岐阜店': '050-1748-2670' };
  const storePhone = branchPhones[order.branchName] || "0564-23-8861";

  return `「肉弁当専門店かつらです」\n${order.customerName}様\nこの度はご注文ありがとうございます。\n下記内容にて明日${dateStr}${weekDay}曜日 ${order.deliveryTime}に${isPickup ? "お待ちしております" : "お届けいたします"}。\n\n受取人：${order.receiverName || order.customerName}様\n${isPickup ? '引取店舗' : '配達先住所'}：${order.address}\n連絡先：${order.phoneNumber || order.phoneDisplay}\n\nー注文内容ー\n${itemsText}\nーお支払い金額ー\n${order.totalPrice}円（税込）\n\n容器回収日時：${trashInfo}\n回収場所：${order.trashPickupLocationDetail || '配達場所と同じ'}\n\n内容に不備がある場合お気軽にお電話ください\n${storePhone}`;
}
