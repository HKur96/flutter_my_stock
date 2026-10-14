# PRD — Aplikasi Koordinasi MrktPlace

## 1. Product Overview

### Nama Produk
MrktPlace.

### Deskripsi
Aplikasi untuk membantu pemilik toko marketplace mengoordinasikan proses fulfillment order dengan anggota operator yang berada di rumah.

Pemilik toko dapat memasukkan order marketplace ke aplikasi, kemudian operator di rumah mendapatkan instruksi pengambilan barang berdasarkan SKU, produk, varian, lokasi, dan foto produk.

Pemilik tetap memiliki kontrol penuh terhadap order sampai order berstatus `DONE`.

### Target User

#### Owner
Pemilik toko yang:
- Berjualan melalui marketplace.
- Sering berada di luar rumah.
- Tidak dapat mengambil dan mengemas barang sendiri.
- Memiliki anggota operator di rumah yang dapat membantu fulfillment.

#### Operator
Anggota operator yang:
- Berada di rumah.
- Tidak terbiasa menggunakan dashboard marketplace.
- Bertugas mengambil, mengemas, dan menyerahkan barang kepada kurir.
- Mengikuti instruksi yang diberikan aplikasi.

---

# 2. Problem

Ketika owner sedang berada di luar rumah dan mendapatkan order marketplace:

1. Barang berada di rumah.
2. Owner tidak dapat melakukan picking.
3. Operator tidak mengetahui barang apa yang harus diambil.
4. Operator mungkin kesulitan memahami order marketplace.
5. Order dapat berubah atau dibatalkan ketika proses picking sedang berlangsung.
6. Owner tetap membutuhkan kontrol terhadap proses fulfillment.

---

# 3. Solution

Aplikasi menyediakan workflow:

Marketplace
→ Input Order
→ Queue
→ Picking
→ Photo Verification
→ Owner Verification
→ Packing
→ Ready
→ Courier
→ Done

Aplikasi menggunakan:

- Flutter
- Provider
- Supabase Auth
- Supabase PostgreSQL
- Supabase Storage
- Supabase Realtime
- Firebase Cloud Messaging

---

# 4. Core Business Principles

## 4.1 Owner adalah decision maker

Owner memiliki kontrol penuh terhadap order sampai sebelum `DONE`.

Owner dapat:
- Mengubah order.
- Menambah item.
- Menghapus item.
- Mengubah quantity.
- Mengubah variant.
- Membatalkan order.
- Memverifikasi hasil picking.

Operator tidak dapat:
- Membatalkan order.
- Mengubah isi order.
- Mengubah quantity.
- Mengubah status bisnis secara bebas.

---

## 4.2 Operator adalah executor

Operator mengikuti instruksi terbaru dari aplikasi.

Operator bertugas:
- Mengambil barang.
- Melaporkan barang tidak ditemukan.
- Mengirim foto hasil picking.
- Melakukan re-picking.
- Packing.
- Menyerahkan paket ke kurir.

---

## 4.3 Backend adalah source of truth

Supabase/PostgreSQL merupakan sumber kebenaran.

Flutter hanya menampilkan dan mengubah state berdasarkan data server.

Supabase Realtime hanya digunakan untuk memberi tahu client bahwa terdapat perubahan.

---

# 5. Product Catalog

Setiap produk memiliki:

- SKU
- Nama produk
- Variant
- Foto
- Lokasi fisik
- Status aktif/nonaktif

Contoh:

SKU:
`BX21-BL-L`

Produk:
`Celana BX21`

Variant:
`Biru / L`

Lokasi:
`Rak A1`

SKU tetap ditampilkan kepada Operator.

---

# 6. Order Input

MVP tidak menggunakan integrasi marketplace.

Owner memasukkan order secara manual atau copy-paste dari marketplace.

Contoh:

Order #SPX12345

BX21-BL-L × 2
ANK-RH-XL × 1
CD01-BK-M × 1

Sistem melakukan matching SKU terhadap product catalog.

Jika seluruh item ditemukan:

`3/3 item dikenali`

Jika terdapat item yang tidak dikenali:

`1 item tidak dikenali`

Owner harus melakukan mapping sebelum order dapat diproses.

---

# 7. Order Queue

Order menggunakan FIFO.

Urutan berdasarkan waktu order dimasukkan ke aplikasi.

Bukan berdasarkan timestamp marketplace.

Hanya satu order yang dapat aktif dikerjakan operator pada satu waktu.

Contoh:

A001 → PICKING
A002 → QUEUED
A003 → QUEUED

A002 dan A003 tidak dapat dikerjakan sampai order aktif selesai atau dibatalkan.

---

# 8. Order Status

Status:

- `QUEUED`
- `PICKING`
- `WAITING_VERIFICATION`
- `RE_PICKING`
- `VERIFIED`
- `PACKING`
- `READY`
- `DONE`
- `CANCELLED`

Normal workflow:

QUEUED
→ PICKING
→ WAITING_VERIFICATION
→ VERIFIED
→ PACKING
→ READY
→ DONE

Jika verification gagal:

WAITING_VERIFICATION
→ RE_PICKING
→ WAITING_VERIFICATION

Jika owner membatalkan:

ANY STATUS BEFORE DONE
→ CANCELLED

`DONE` adalah status terminal.

---

# 9. Picking Workflow

Ketika order menjadi aktif:

Operator melihat:

`Order A001`

Operator mengerjakan item satu per satu.

Setiap item menampilkan:

- Nomor item.
- SKU.
- Nama produk.
- Variant.
- Quantity.
- Lokasi.
- Foto produk.
- Status picking.

Contoh:

BARANG 1 DARI 3

SKU:
`BX21-BL-L`

Jumlah:
`2 pcs`

Lokasi:
`Rak A1`

Action:

`SUDAH DIAMBIL`

---

# 10. Partial Picking

Sistem menyimpan:

- Quantity yang harus diambil.
- Quantity yang sudah diambil.

Contoh:

Required:
3

Picked:
2

Remaining:
1

Status:

`PARTIAL`

Operator tidak perlu mengulang item yang sudah benar.

---

# 11. Picking Completion

Setelah seluruh item selesai:

Operator melihat:

`Semua barang sudah diambil.`

Operator mengambil satu foto seluruh barang.

Foto dikirim ke owner.

Status:

`WAITING_VERIFICATION`

---

# 12. Verification

Owner melihat:

- Order ID.
- Semua item.
- Quantity.
- Foto hasil picking.

Owner memiliki dua pilihan:

`SEMUA SESUAI`

atau

`ADA YANG TIDAK SESUAI`

---

# 13. Verification Passed

Jika semua sesuai:

WAITING_VERIFICATION
→ VERIFIED

Operator mendapatkan instruksi:

`Silakan packing order.`

---

# 14. Verification Failed

Owner memilih SKU yang bermasalah.

Alasan:

- `WRONG_PRODUCT`
- `WRONG_VARIANT`
- `WRONG_QUANTITY`
- `MISSING_ITEM`
- `OTHER`

Hanya SKU yang bermasalah yang masuk re-picking.

Contoh:

BX21 → benar
ANK → salah
CD01 → benar

Operator hanya melakukan re-pick ANK.

Setelah selesai:

RE_PICKING
→ WAITING_VERIFICATION

Owner melakukan verifikasi ulang.

---

# 15. Photo Verification

Foto dapat ditolak karena:

- Blur.
- Terlalu gelap.
- Barang tertutup.
- Quantity tidak terlihat.
- Foto tidak cukup untuk melakukan verifikasi.

Jika masalah hanya foto:

Operator cukup mengambil foto ulang.

Tidak perlu melakukan re-picking.

---

# 16. Edit Order

Owner dapat mengedit order pada semua status kecuali `DONE`.

Edit dapat berupa:

- Menambah item.
- Menghapus item.
- Mengubah quantity.
- Mengubah variant.
- Mengubah informasi order lainnya.

Jika perubahan memengaruhi barang, proses picking harus menyesuaikan kondisi terbaru.

Contoh:

BX21 × 2
diubah menjadi
BX21 × 3

Operator hanya perlu mengambil 1 tambahan jika sebelumnya sudah mengambil 2.

Jika item yang sudah diambil dihapus, operator harus mengembalikan item tersebut.

Jika item baru ditambahkan, operator hanya mengambil item baru.

---

# 17. Edit Setelah Verification

Jika order sudah `VERIFIED` kemudian isi barang berubah, hasil verification sebelumnya tidak lagi dianggap valid untuk item yang terdampak.

Order harus kembali ke proses yang diperlukan.

Contoh:

VERIFIED
→ Order berubah
→ PICKING

Tidak perlu mengulang item yang tidak terdampak.

---

# 18. Edit Saat Packing

Jika order sedang `PACKING` kemudian isi barang berubah:

PACKING
→ PICKING

Operator harus mengikuti instruksi terbaru.

---

# 19. Edit Saat READY

Owner tetap dapat mengedit order selama belum `DONE`.

Jika perubahan memerlukan perubahan barang:

READY
→ PICKING

Paket dapat dibuka kembali dan disesuaikan.

---

# 20. Cancel Order

Owner dapat membatalkan order pada semua status kecuali `DONE`.

Contoh:

PICKING
→ CANCELLED

Operator menerima instruksi:

`Order A001 dibatalkan. Jangan lanjutkan proses.`

Order yang dibatalkan tidak lagi menghalangi queue.

---

# 21. Realtime

Supabase Realtime digunakan untuk mendeteksi perubahan order.

Contoh:

Owner:
`UPDATE A001`

Supabase:
`Database changed`

Opeator:
`Realtime event`

Provider:
`Refresh active order`

UI:
`Menampilkan data terbaru`

Realtime bukan source of truth.

Database tetap menjadi source of truth.

---

# 22. Push Notification

Firebase Cloud Messaging digunakan untuk notifikasi penting.

Contoh:

- Order baru tersedia.
- Order diubah.
- Order dibatalkan.
- Order menunggu verification.
- Verification gagal.
- Order siap dipacking.
- Order siap diserahkan.

Jika aplikasi operator aktif, Realtime memperbarui UI.

Jika aplikasi berada di background/tertutup, FCM memberikan notifikasi.

---

# 23. Offline Handling

Operator dapat melihat data terakhir yang sudah disinkronkan.

Jika koneksi terputus:
- Data terakhir tetap dapat ditampilkan.
- Perubahan server tidak dapat diketahui sampai koneksi kembali.
- Action yang membutuhkan server tidak dianggap berhasil sebelum mendapat konfirmasi.

Ketika koneksi kembali:

Reconnect
→ Sync active order
→ Ambil state terbaru dari Supabase
→ Update Provider

Jika owner telah membatalkan order ketika operator offline, state terbaru dari server harus menang.

---

# 24. Order Version

Setiap order memiliki `version`.

Contoh:

version 7

Owner mengubah order:

version 8

Client operator menerima event lama version 7 setelah version 8.

Client mengabaikan version 7.

Tujuan:
- Mencegah stale update.
- Membantu sinkronisasi.
- Mencegah state lama menimpa state terbaru.

---

# 25. Order Events

Setiap perubahan penting dicatat dalam `order_events`.

Contoh:

- `ORDER_CREATED`
- `ORDER_UPDATED`
- `ORDER_CANCELLED`
- `PICKING_STARTED`
- `ITEM_PICKED`
- `SUBMITTED_FOR_VERIFICATION`
- `VERIFICATION_FAILED`
- `RE_PICKING_STARTED`
- `VERIFIED`
- `PACKING_STARTED`
- `READY`
- `HANDED_TO_COURIER`
- `DONE`

Tujuan:
- Audit.
- Debugging.
- Riwayat aktivitas.
- Mengetahui siapa yang melakukan perubahan.

---

# 26. Packing

Setelah `VERIFIED`:

Operator melakukan packing.

Action:

`SUDAH DIPACKING`

Status:

PACKING
→ READY

---

# 27. Courier Handover

Ketika kurir datang:

Operator menekan:

`SUDAH DISERAHKAN KE KURIR`

Status:

READY
→ DONE

Setelah `DONE`:
- Order tidak dapat diedit.
- Order tidak dapat dibatalkan.
- Order menjadi final.

---

# 28. Owner Features — MVP

- Login.
- Setup toko.
- CRUD product.
- SKU management.
- Location management.
- Product photo.
- Input order.
- SKU matching.
- Queue management.
- Edit order.
- Cancel order.
- View active order.
- Verification.
- Partial re-pick.
- View order history.
- View order events.

---

# 29. Operator Features — MVP

- Login.
- View active order.
- View queue.
- View SKU.
- View product.
- View variant.
- View quantity.
- View location.
- View product photo.
- Mark item picked.
- Report item not found.
- Upload picking photo.
- Re-pick incorrect items.
- Packing.
- Mark ready.
- Mark courier handover.
- Receive notifications.

---

# 30. Non-Goals MVP

Tidak termasuk:

- Marketplace API.
- Auto-sync marketplace.
- Inventory management penuh.
- Stock deduction otomatis.
- Barcode scanner.
- Courier API.
- Shipping label.
- Payment.
- Accounting.
- Multi-warehouse.
- Analytics kompleks.
- Internal chat.

---

# 31. Technology Stack

Frontend:
- Flutter
- Provider
- Dio
- Local persistence

Backend:
- Supabase
- PostgreSQL
- Supabase Auth
- Supabase Storage
- Supabase Realtime

Notification:
- Firebase Cloud Messaging

Architecture principle:

`Database → Source of Truth`

`Realtime → Change Signal`

`Provider → Client State`

`FCM → Background Notification`