hereimport os
import logging
from telegram import Update
from telegram.ext import (
    Application,
    MessageHandler,
    ContextTypes,
    filters,
)
from telegram.error import TelegramError

# =========================
# إعدادات البوت
# =========================

TOKEN = os.getenv("BOT_TOKEN")

if not TOKEN:
    raise ValueError("لم يتم العثور على BOT_TOKEN")

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO
)


# =========================
# التحقق من أن الشخص مشرف
# =========================

async def is_admin(update: Update, user_id: int) -> bool:
    try:
        member = await update.effective_chat.get_member(user_id)
        return member.status in ("administrator", "creator")
    except TelegramError:
        return False


# =========================
# تنفيذ أوامر الإدارة
# =========================

async def moderation(update: Update, context: ContextTypes.DEFAULT_TYPE):

    message = update.effective_message

    if not message or not message.text:
        return

    # لازم يكون الأمر على رسالة شخص
    if not message.reply_to_message:
        return

    user = update.effective_user

    # فقط المشرفون يستطيعون استخدام أوامر الإدارة
    if not await is_admin(update, user.id):
        return

    target = message.reply_to_message.from_user

    # لا تحاول إدارة البوت نفسه
    if target.is_bot:
        return

    command = message.text.strip().lower()

    # =========================
    # كت = كتم
    # =========================

    if command == "كت":

        try:
            await context.bot.restrict_chat_member(
                chat_id=update.effective_chat.id,
                user_id=target.id,
                permissions={
                    "can_send_messages": False,
                    "can_send_audios": False,
                    "can_send_documents": False,
                    "can_send_photos": False,
                    "can_send_videos": False,
                    "can_send_video_notes": False,
                    "can_send_voice_notes": False,
                    "can_send_polls": False,
                    "can_send_other_messages": False,
                    "can_add_web_page_previews": False,
                    "can_change_info": False,
                    "can_invite_users": False,
                    "can_pin_messages": False,
                }
            )

            await message.reply_text(
                f"🔇 تم كتم {target.first_name}"
            )

        except TelegramError as e:
            await message.reply_text(
                f"❌ ما قدرت أكتمه:\n{e}"
            )

        return


    # =========================
    # نهائي = حظر
    # =========================

    if command == "نهائي":

        try:
            await context.bot.ban_chat_member(
                chat_id=update.effective_chat.id,
                user_id=target.id
            )

            await message.reply_text(
                f"🔨 تم تبنيد {target.first_name} نهائيًا."
            )

        except TelegramError as e:
            await message.reply_text(
                f"❌ ما قدرت أبنده:\n{e}"
            )

        return


    # =========================
    # مش = إعطاء مشرف
    # =========================

    if command == "مش":

        try:
            await context.bot.promote_chat_member(
                chat_id=update.effective_chat.id,
                user_id=target.id,

                can_manage_chat=True,
                can_delete_messages=True,
                can_manage_video_chats=True,
                can_restrict_members=True,
                can_promote_members=False,
                can_change_info=True,
                can_invite_users=True,
                can_pin_messages=True,
                can_manage_topics=True
            )

            await message.reply_text(
                f"👑 تم إعطاء {target.first_name} رتبة مشرف."
            )

        except TelegramError as e:
            await message.reply_text(
                f"❌ ما قدرت أعطيه مشرف:\n{e}"
            )

        return


# =========================
# الردود التلقائية
# =========================

async def auto_replies(update: Update, context: ContextTypes.DEFAULT_TYPE):

    message = update.effective_message

    if not message or not message.text:
        return

    text = message.text.strip().lower()

    # السلام عليكم
    if text == "السلام عليكم":
        await message.reply_text("منوووررر وعليكم السلام")
        return

    # اه
    if text == "اه":
        await message.reply_text("جوييييي")
        return

    # هاي
    if text == "هاي":
        await message.reply_text("هايات وش جابك؟")
        return

    # تسطير
    if text == "تسطير":
        await message.reply_text("يشيخ اذلف")
        return


# =========================
# البحث عن أغنية في يوتيوب
# =========================

async def youtube_search(update: Update, context: ContextTypes.DEFAULT_TYPE):

    message = update.effective_message

    if not message or not message.text:
        return

    text = message.text.strip()

    # لازم يبدأ بـ يوت
    if not text.lower().startswith("يوت"):
        return

    search = text[3:].strip()

    if not search:
        await message.reply_text(
            "🎵 اكتب اسم الأغنية بعد يوت\n\n"
            "مثال:\n"
            "يوت Blinding Lights"
        )
        return

    # البحث باستخدام YouTube عبر yt-dlp
    try:
        import yt_dlp

        options = {
            "quiet": True,
            "no_warnings": True,
            "extract_flat": True,
            "default_search": "ytsearch5",
        }

        with yt_dlp.YoutubeDL(options) as ydl:

            results = ydl.extract_info(
                f"ytsearch5:{search}",
                download=False
            )

        entries = results.get("entries", [])

        if not entries:
            await message.reply_text(
                "❌ ما لقيت الأغنية."
            )
            return

        reply = "🎵 نتائج البحث:\n\n"

        for i, video in enumerate(entries[:5], start=1):

            title = video.get("title", "بدون عنوان")
            video_id = video.get("id")

            if video_id:
                url = f"https://www.youtube.com/watch?v={video_id}"

                reply += (
                    f"{i}. {title}\n"
                    f"{url}\n\n"
                )

        await message.reply_text(reply)

    except Exception as e:

        await message.reply_text(
            "❌ حدث خطأ أثناء البحث في يوتيوب."
        )

        print("YouTube error:", e)


# =========================
# تشغيل البوت
# =========================

def main():

    app = Application.builder().token(TOKEN).build()

    # أوامر الإدارة
    app.add_handler(
        MessageHandler(
            filters.TEXT & filters.ChatType.GROUPS,
            moderation
        )
    )

    # يوت
    app.add_handler(
        MessageHandler(
            filters.TEXT & filters.ChatType.GROUPS,
            youtube_search
        )
    )

    # الردود التلقائية
    app.add_handler(
        MessageHandler(
            filters.TEXT & filters.ChatType.GROUPS,
            auto_replies
        )
    )

    print("🤖 البوت يعمل...")
    app.run_polling()


if __name__ == "__main__":
    main()
