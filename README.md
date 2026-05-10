# weekly-life-planner-ai

> Yapay zeka destekli haftalık yaşam planlayıcısı — Telegram + n8n + Supabase + OpenAI

**Yazar:** Beyza Ata · [GitHub @ataabeeyzaa](https://github.com/ataabeeyzaa)
**Ders:** Veri Tabanı (Database-AI Entegrasyonu)
**Teslim:** 18 Mayıs 2026

## Ne yapar?

Telegram'da `@PlanlaBot`'a profilinizi anlatırsınız (uyanma saati, hedefler, iş düzeniniz). Her Pazar 20:00'de bot geçen haftayı sorar, AI sizin için kişiselleştirilmiş bir haftalık plan üretir, mesaj olarak gönderir. Tüm veri Supabase PostgreSQL'de saklanır, otomasyon n8n ile yapılır.

## Mimari

```
Kullanıcı (Telegram)
       ↓
Telegram Bot ↔ n8n (Docker)
       ↓
   Supabase + OpenAI gpt-4o-mini
```

Detay: [docs/superpowers/specs/2026-05-10-weekly-life-planner-ai-design.md](docs/superpowers/specs/2026-05-10-weekly-life-planner-ai-design.md)

## Geliştirme Durumu

Bu repo aktif olarak inşa ediliyor. İlerleyen fazlarda eklenecek:

- ✅ Tasarım dokümanı (Phase 0)
- ✅ İmplementasyon planı (Phase 0)
- ⏳ Veritabanı şeması (Phase 1)
- ⏳ n8n workflow'lar (Phase 3-5)
- ⏳ Demo videosu (Phase 7)
- ⏳ IEEE makalesi (Phase 8)

## Hızlı Başlangıç

(Tüm fazlar tamamlandıktan sonra eklenecek.)

## Demo

- 🎬 Demo videosu: (eklenecek)
- 📄 IEEE makalesi: `docs/ieee-paper/` (eklenecek)

## Lisans

MIT — bkz. [LICENSE](LICENSE).
