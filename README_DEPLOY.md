# راهنمای دیپلوی AURA Gateway روی سه پلتفرم

---

## ۱. Railway.app

### فایل‌های مورد نیاز
- `main.py`
- `railway.toml`

### مراحل
1. یک پروژه جدید در [railway.app](https://railway.app) بسازید
2. ریپو GitHub خود را connect کنید (یا با `railway up` از CLI دیپلوی کنید)
3. متغیرهای محیطی زیر را در بخش **Variables** تنظیم کنید:

| متغیر | مقدار |
|-------|-------|
| `ADMIN_TOKEN` | یک رمز قوی |
| `ADMIN_PATH` | مثلاً `mypanel` |
| `PUBLIC_HOST` | دامنه Railway مثلاً `aura.up.railway.app` |

4. بعد از اولین دیپلوی، دامنه‌ی اختصاصی را از تب **Settings → Domains** بگیرید و در `PUBLIC_HOST` قرار دهید
5. دوباره دیپلوی کنید

---

## ۲. Render.com

### فایل‌های مورد نیاز
- `main.py`
- `Dockerfile`

### مراحل
1. در [render.com](https://render.com) یک **Web Service** جدید بسازید
2. نوع را **Docker** انتخاب کنید
3. ریپو GitHub را متصل کنید
4. متغیرهای محیطی زیر را در بخش **Environment** تنظیم کنید:

| متغیر | مقدار |
|-------|-------|
| `ADMIN_TOKEN` | یک رمز قوی |
| `ADMIN_PATH` | مثلاً `mypanel` |
| `PUBLIC_HOST` | دامنه Render مثلاً `aura.onrender.com` |

5. **Health Check Path** را روی `/` بگذارید
6. پلن رایگان Render هر ۱۵ دقیقه idle می‌شود — برای استفاده دائمی پلن پولی بگیرید

---

## ۳. Wasmer Edge (wasmer.io)

### ساختار فایل‌ها
```
project/
├── src/
│   └── main.py          ← فایل اصلی اپلیکیشن
├── data/
│   └── .gitkeep         ← دایرکتوری برای SQLite
├── wasmer.toml          ← تنظیمات پکیج Wasmer
└── app.yaml             ← تنظیمات دیپلوی Wasmer Edge
```

### پیش‌نیازها

```bash
# نصب Wasmer CLI
curl https://get.wasmer.io -sSfL | sh

# لاگین
wasmer login
```

### مراحل دیپلوی

**۱. ویرایش `wasmer.toml`**

خط `name` را با username خود در Wasmer تغییر دهید:
```toml
[package]
name = "YOUR_WASMER_USERNAME/aura-gateway"
```

**۲. ویرایش `app.yaml`**

```yaml
owner: YOUR_WASMER_USERNAME
package: YOUR_WASMER_USERNAME/aura-gateway
```
همچنین `ADMIN_TOKEN` و `ADMIN_PATH` را تغییر دهید.

**۳. محیط مجازی Python و نصب وابستگی‌ها**

```bash
python -m venv .env
source .env/bin/activate   # Linux/Mac
# یا: .env\Scripts\activate  # Windows

pip install fastapi "uvicorn[standard]" psutil
```

**۴. دیپلوی**

```bash
wasmer deploy
```

در اولین بار، CLI سؤالاتی می‌پرسد — نام اپ و owner را وارد کنید.

**۵. تنظیم PUBLIC_HOST**

بعد از دیپلوی، URL اپ‌تان را بگیرید (مثلاً `aura-gateway-myuser.wasmer.app`) و در `app.yaml` تنظیم کنید:

```yaml
env:
  PUBLIC_HOST: "aura-gateway-myuser.wasmer.app"
```

سپس دوباره دیپلوی کنید:
```bash
wasmer deploy
```

**۶. افزودن Persistent Volume (اختیاری ولی توصیه‌شده)**

برای اینکه داده‌های SQLite بین ری‌استارت‌ها حفظ شوند، یک Volume در داشبورد Wasmer بسازید و به مسیر `/app/data` متصل کنید.

### متغیرهای محیطی Wasmer

متغیرها را از طریق CLI تنظیم کنید:
```bash
wasmer app secret set ADMIN_TOKEN "your_strong_token"
wasmer app secret set ADMIN_PATH "mypanel"
wasmer app secret set PUBLIC_HOST "aura-gateway-myuser.wasmer.app"
```

یا مستقیم در `app.yaml` زیر بخش `env` قرار دهید.

---

## نکات مشترک

- پنل ادمین در مسیر `/{ADMIN_PATH}` قابل دسترس است
- پس از دیپلوی، لینک‌های VLESS از طریق پنل قابل دریافت‌اند
- هر سه پلتفرم TLS را خودشان مدیریت می‌کنند (پورت ۴۴۳)
- برای امنیت، `ADMIN_TOKEN` پیش‌فرض (`aura_secret_2026`) را حتماً تغییر دهید
