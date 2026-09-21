import json
import os
import urllib.request

def handler(event, context):
    """
    SNS → Lambda → Slack 通知
    CloudWatchアラームの状態変化をSlackに日英バイリンガルで通知する
    Bilingual (JA/EN) Slack notification via SNS → Lambda
    """
    webhook_url = os.environ["SLACK_WEBHOOK_URL"]

    for record in event["Records"]:
        sns_message = json.loads(record["Sns"]["Message"])

        alarm_name = sns_message.get("AlarmName", "Unknown / 不明")
        new_state = sns_message.get("NewStateValue", "Unknown / 不明")
        reason = sns_message.get("NewStateReason", "No reason provided / 理由不明")
        region = sns_message.get("Region", "ap-northeast-1")

        # 状態に応じて絵文字・緊急度・文言を変える
        # Emoji, severity and label based on alarm state
        if new_state == "ALARM":
            emoji = "🚨"
            status_ja = "障害検知"
            status_en = "Incident Detected"
            severity = "P1 - Immediate / 即時対応"
        elif new_state == "OK":
            emoji = "✅"
            status_ja = "復旧確認"
            status_en = "Recovered"
            severity = "P3 - Resolved / 復旧済み"
        else:
            emoji = "⚠️"
            status_ja = "状態変化"
            status_en = "State Changed"
            severity = "P2 - Monitor / 経過観察"

        message = {
            "text": (
                f"{emoji} *AWS CloudWatch Alert — {status_en} / {status_ja}*\n"
                f"*Alarm / アラーム名：* {alarm_name}\n"
                f"*State / 状態：* {new_state}\n"
                f"*Severity / 緊急度：* {severity}\n"
                f"*Reason / 理由：* {reason}\n"
                f"*Region / リージョン：* {region}\n"
                f"*Action Required / 対応をお願いします：* AWS Console → CloudWatch Alarms"
            )
        }

        req = urllib.request.Request(
            webhook_url,
            data=json.dumps(message).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        with urllib.request.urlopen(req) as res:
            print(f"Slack response: {res.status}")

    return {"statusCode": 200}