# PRD — PERSONAL STOCK MANAGER

## 1. Product Overview

**Nama aplikasi:** Personal Stock Manager

**Platform:** Flutter Mobile (Android/iOS)

**Backend:** Supabase

**Database:** PostgreSQL (Supabase)

**Authentication:** Supabase Auth

**State Management:** Provider

**Target pengguna:** Penggunaan pribadi

**Mode:** Cloud-based, multi-device

### Tujuan

Aplikasi digunakan untuk mencatat, memantau, dan mengontrol stok barang secara sederhana dari beberapa device.

Fokus utama aplikasi:

1. Mengelola produk.
2. Mengelola kategori.
3. Mencatat stok masuk.
4. Mencatat stok keluar.
5. Melakukan stok opname.
6. Melihat histori perubahan stok.
7. Scan QR Code untuk mencari produk berdasarkan SKU.
8. Sinkronisasi data antar-device.
9. Menampilkan stok terkini.

Aplikasi bukan POS dan bukan aplikasi akuntansi.

---

# 2. Technology Stack

## Mobile

- Flutter
- Dart
- Provider
- QR/Barcode Scanner package
- Supabase Flutter SDK

## Backend

- Supabase Auth
- Supabase PostgreSQL
- Supabase Realtime
- PostgreSQL Functions / RPC
- Row Level Security (RLS)

---

# 3. Authentication

MVP hanya menggunakan:

- Email
- Password
- Login
- Logout

Tidak menyediakan:

- Register dari aplikasi
- Google Login
- Apple Login
- Social Login

Account dapat dibuat melalui Supabase Dashboard atau mekanisme admin terpisah.

### Authentication Flow

```text
Splash
   ↓
Check Supabase Session
   ├── Session exists → Dashboard
   └── No session → Login
```

Jika session expired:

```text
Current Screen
   ↓
Supabase Auth Error
   ↓
Login
```

---

# 4. User Model

MVP hanya memiliki satu role:

```text
OWNER
```

Tidak ada:

- Admin
- Staff
- Cashier
- Viewer

Semua data inventory dimiliki oleh user berdasarkan `user_id`.

Setiap query dan mutation wajib dibatasi berdasarkan authenticated user.

---

# 5. Product

## Product Fields

| Field | Required | Description |
|---|---|---|
| Name | Yes | Nama produk |
| SKU | No | Kode produk unik per user |
| Category | Yes | Kategori produk |
| Purchase Price | Yes | Harga beli |
| Recommended Selling Price | Yes | Rekomendasi harga jual |
| Minimum Stock | No | Batas stok rendah |
| Current Stock | System | Stok saat ini |
| Is Active | System | Status produk |
| Created At | System | Waktu dibuat |
| Updated At | System | Waktu diperbarui |

### SKU Rules

- SKU bersifat optional.
- Jika SKU diisi, SKU harus unik untuk user tersebut.
- SKU dapat dimasukkan manual.
- SKU dapat diisi melalui QR Scanner.
- QR Code berisi SKU.
- Produk tanpa SKU tetap dapat digunakan melalui search/manual selection.

Contoh:

```text
SKU:
ANK-001

QR Payload:
ANK-001
```

QR Code bukan primary key database.

---

# 6. Category

Kategori digunakan untuk mengelompokkan produk.

Contoh:

```text
Makanan
Minuman
ATK
Elektronik
Aksesoris
Lainnya
```

User dapat:

- Melihat kategori.
- Menambah kategori.
- Mengedit kategori.
- Menghapus kategori yang tidak sedang digunakan.

Kategori yang masih digunakan oleh produk tidak boleh dihapus secara paksa.

---

# 7. Current Stock

`current_stock` menyimpan stok terkini.

Namun `current_stock` bukan satu-satunya sumber histori.

Setiap perubahan stok wajib menghasilkan `stock_transaction`.

Contoh:

```text
Stock awal       10
Stock In        +20
Stock Out        -3
Stock Out        -2
Opname           -1
-------------------
Current Stock    24
```

---

# 8. Stock In

Stock In digunakan ketika stok bertambah.

### Input

- Product
- Quantity
- Purchase Price
- Date/Time
- Note

### Example

```text
Product: Produk A
Quantity: 20
Purchase Price: Rp8.000
Note: Restock supplier
```

Jika stok sebelumnya:

```text
10
```

maka:

```text
10 + 20 = 30
```

### Rules

- Quantity harus > 0.
- Purchase price >= 0.
- Product harus aktif.
- Transaksi dilakukan melalui database RPC.
- Stock transaction dan perubahan current stock harus terjadi secara atomic.

---

# 9. Stock Out

Stock Out digunakan ketika stok berkurang.

### Input

- Product
- Quantity
- Reason
- Date/Time
- Note

### Reason

```text
Terjual
Rusak
Hilang
Dipakai Pribadi
Lainnya
```

### Rules

Quantity tidak boleh melebihi current stock.

Contoh:

```text
Current Stock = 10
Stock Out = 11
```

Transaction harus ditolak.

Error:

```text
Stok tidak mencukupi.
Stok tersedia: 10
Jumlah diminta: 11
```

---

# 10. Stock Opname

Stock Opname digunakan untuk mencocokkan stok sistem dengan stok fisik.

### Input

- Product
- Physical Stock
- Note

### System-generated

- System Stock
- Difference
- Adjustment

Example:

```text
System Stock   = 20
Physical Stock = 18
Difference     = -2
```

Setelah dikonfirmasi:

```text
Current Stock = 18
```

Stock opname juga harus menghasilkan stock transaction.

---

# 11. Stock Transaction

Semua perubahan stok harus dicatat.

Jenis transaksi:

```text
IN
OUT
OPNAME
```

Setiap transaction menyimpan:

- Product
- Type
- Quantity
- Adjustment
- Purchase Price
- Reason
- Note
- Stock Before
- Stock After
- Created At
- User

### Adjustment

Adjustment menunjukkan dampak transaksi terhadap stok.

Contoh:

```text
IN
quantity   = 20
adjustment = +20
```

```text
OUT
quantity   = 3
adjustment = -3
```

```text
OPNAME
quantity   = 2
adjustment = -2
```

---

# 12. Transaction History

User dapat melihat semua perubahan stok.

Filter:

```text
Semua
Stok Masuk
Stok Keluar
Opname
```

Data ditampilkan dari terbaru ke terlama.

Example:

```text
06 Okt 2026

+20  Produk A
     Stok Masuk

-3   Produk B
     Terjual

-2   Produk C
     Opname
```

---

# 13. QR Scanner

QR Scanner adalah fitur utama.

QR Code berisi SKU.

Example:

```text
QR:
ANK-001
```

### Scan Flow

```text
Scan QR
   ↓
Read payload
   ↓
Normalize SKU
   ↓
Search product by user_id + SKU
```

Jika ditemukan:

```text
Product Found
   ↓
Product Quick Action
```

Jika tidak ditemukan:

```text
SKU belum terdaftar

[ Buat Produk ]
[ Scan Lagi ]
```

---

# 14. QR Scanner dari Dashboard

Dashboard menyediakan tombol:

```text
Scan QR
```

Flow:

```text
Dashboard
   ↓
Scan QR
   ↓
Product Found
   ↓
Product Quick Action
```

Quick actions:

```text
Stok Masuk
Stok Keluar
Lihat Produk
```

---

# 15. Add Product

Form:

```text
Nama Produk *
SKU
Kategori *
Harga Beli *
Rekomendasi Harga Jual *
Minimum Stok
```

SKU dapat:

```text
Input manual
```

atau:

```text
Scan QR
```

Jika SKU sudah digunakan:

```text
SKU sudah digunakan oleh produk lain.
```

---

# 16. Edit Product

User dapat mengubah:

- Name
- SKU
- Category
- Purchase Price
- Recommended Selling Price
- Minimum Stock
- Is Active

Mengubah harga produk tidak mengubah histori harga pada transaksi sebelumnya.

---

# 17. Product Detail

Menampilkan:

```text
Nama Produk
SKU
Kategori
Current Stock
Purchase Price
Recommended Selling Price
Minimum Stock
```

Actions:

```text
Stok Masuk
Stok Keluar
Stok Opname
Edit Produk
```

Menampilkan beberapa transaksi terakhir.

---

# 18. Low Stock

Jika:

```text
current_stock <= minimum_stock
```

maka produk dianggap low stock.

Dashboard menampilkan daftar produk low stock.

Example:

```text
Produk A     3 pcs
Produk B     2 pcs
Produk C     0 pcs
```

---

# 19. Dashboard

Dashboard menampilkan informasi sederhana.

### Summary

```text
Total Produk
Total Item
Nilai Persediaan
```

### Quick Actions

```text
Scan QR
Stok Masuk
Stok Keluar
Stok Opname
```

### Low Stock

Menampilkan produk dengan stok rendah.

### Recent Transactions

Menampilkan beberapa transaksi terbaru.

Dashboard tidak perlu laporan kompleks pada MVP.

---

# 20. Inventory Value

Nilai persediaan MVP dihitung:

```text
SUM(current_stock × purchase_price)
```

Contoh:

```text
Produk A
20 × Rp8.000 = Rp160.000

Produk B
10 × Rp5.000 = Rp50.000

Total:
Rp210.000
```

Nilai ini adalah estimasi berdasarkan harga beli produk saat ini.

---

# 21. Average Cost

Average cost belum menjadi fitur utama MVP.

Namun transaksi menyimpan `purchase_price` agar fitur valuasi inventory yang lebih akurat dapat ditambahkan di masa depan.

Contoh:

```text
10 pcs × Rp8.000
10 pcs × Rp9.000
```

Average:

```text
Rp8.500
```

---

# 22. Multi-device

Semua device menggunakan Supabase sebagai source of truth.

Architecture:

```text
Device A ─┐
Device B ─┼── Supabase PostgreSQL
Device C ─┘
```

Supabase Realtime digunakan agar perubahan dapat terlihat di device lain.

Example:

```text
Device A
Stock = 20

Device B
Stock In +10

Database
20 → 30

Device A
20 → 30
```

---

# 23. Concurrency

Perubahan stok tidak boleh dilakukan dengan update biasa dari Flutter.

Tidak diperbolehkan:

```text
UPDATE products
SET current_stock = current_stock + 10
```

langsung dari client.

Gunakan PostgreSQL RPC/function.

Flow:

```text
Flutter
   ↓
Provider
   ↓
Repository
   ↓
Supabase RPC
   ↓
PostgreSQL transaction
   ├── Lock product
   ├── Validate
   ├── Insert stock transaction
   └── Update current_stock
```

Operation harus atomic.

---

# 24. Delete Product

Produk yang sudah memiliki transaksi tidak boleh di-hard-delete.

Gunakan:

```text
is_active = false
```

Produk inactive:

- Tidak muncul pada daftar produk aktif.
- Tidak dapat digunakan untuk transaksi baru.
- Histori tetap tersedia.

---

# 25. Navigation

Bottom navigation:

```text
Home
Products
History
More
```

Dashboard memiliki prominent action:

```text
Scan QR
```

---

# 26. Screens

## Screen 1 — Splash

Responsibilities:

- Initialize Supabase.
- Check authentication.
- Navigate.

---

## Screen 2 — Login

Fields:

```text
Email
Password
```

Action:

```text
Masuk
```

Tidak ada register.

---

## Screen 3 — Dashboard

Content:

```text
Inventory Overview
Total Produk
Total Item
Nilai Persediaan

Quick Actions
Scan QR
Stok Masuk
Stok Keluar
Stok Opname

Low Stock

Recent Transactions
```

---

## Screen 4 — Products

Features:

- List products.
- Search.
- Category filter.
- Low stock indicator.
- Add product.

---

## Screen 5 — Product Detail

Features:

- Product information.
- Current stock.
- Stock actions.
- Recent history.
- Edit.

---

## Screen 6 — Add/Edit Product

Fields:

```text
Name
SKU
Category
Purchase Price
Recommended Selling Price
Minimum Stock
```

SKU memiliki Scan QR action.

---

## Screen 7 — QR Scanner

Features:

- Camera scanner.
- Detect QR.
- Extract SKU.
- Search product.
- Open product action.

---

## Screen 8 — Stock In

Fields:

```text
Product
Quantity
Purchase Price
Note
```

---

## Screen 9 — Stock Out

Fields:

```text
Product
Quantity
Reason
Note
```

---

## Screen 10 — Stock Opname

Fields:

```text
Product
System Stock
Physical Stock
Difference
Note
```

---

## Screen 11 — Transaction History

Features:

- List transaction.
- Filter by type.
- Search product.
- Open detail.

---

## Screen 12 — Transaction Detail

Displays:

```text
Product
SKU
Type
Quantity
Adjustment
Stock Before
Stock After
Purchase Price
Reason
Note
Date
```

---

## Screen 13 — Categories

Features:

- List category.
- Add.
- Edit.
- Delete if unused.

---

## Screen 14 — Settings

Displays:

```text
Account
Email

Inventory
Categories

App
Logout
```

---

# 27. Main User Flows

## Add Product

```text
Products
 ↓
+
 ↓
Add Product
 ↓
Scan QR / Input SKU
 ↓
Fill Product Data
 ↓
Save
 ↓
Product Created
```

## Stock In

```text
Dashboard
 ↓
Scan QR
 ↓
Product
 ↓
Stok Masuk
 ↓
Input Quantity
 ↓
Input Purchase Price
 ↓
Save
 ↓
Stock Updated
```

## Stock Out

```text
Dashboard
 ↓
Scan QR
 ↓
Product
 ↓
Stok Keluar
 ↓
Input Quantity
 ↓
Select Reason
 ↓
Save
 ↓
Stock Updated
```

## Stock Opname

```text
Stock Opname
 ↓
Scan/Search Product
 ↓
View System Stock
 ↓
Input Physical Stock
 ↓
Calculate Difference
 ↓
Confirm
 ↓
Stock Updated
```

---

# 28. Error Handling

### Network Error

```text
Tidak dapat terhubung ke server.
Periksa koneksi internet dan coba lagi.
```

### SKU Not Found

```text
SKU belum terdaftar.
```

### Duplicate SKU

```text
SKU sudah digunakan oleh produk lain.
```

### Insufficient Stock

```text
Stok tidak mencukupi.
```

### Authentication Error

```text
Sesi telah berakhir.
Silakan login kembali.
```

---

# 29. MVP Out of Scope

Jangan implementasikan pada MVP:

- POS.
- Customer management.
- Supplier management.
- Purchase order.
- Sales order.
- Invoice.
- Accounting.
- Profit/loss.
- Multi-user permission.
- Subscription.
- Payment.
- Complex reporting.
- Export Excel.
- Printer integration.
- Barcode printer.
- Warehouse management.
- Multiple warehouse.
- Batch/lot.
- Expiry date.
- Serial number.

---

# 30. Success Criteria

MVP dianggap selesai apabila user dapat:

1. Login.
2. Membuat kategori.
3. Membuat produk.
4. Menambahkan SKU.
5. Scan QR untuk SKU.
6. Menemukan produk dengan QR.
7. Mencatat stok masuk.
8. Mencatat stok keluar.
9. Mencegah stok keluar melebihi stok tersedia.
10. Melakukan stok opname.
11. Melihat histori stok.
12. Melihat stok rendah.
13. Menggunakan aplikasi dari lebih dari satu device.
14. Melihat perubahan stok antar-device.
15. Memastikan transaksi stok dilakukan secara atomic.
16. Logout.

---

# 31. Development Priority

## Phase 1

```text
Flutter setup
Supabase setup
Auth
Database
RLS
Routing
```

## Phase 2

```text
Category
Product CRUD
Search
Product Detail
```

## Phase 3

```text
QR Scanner
SKU Lookup
```

## Phase 4

```text
Stock In
Stock Out
PostgreSQL RPC
Transaction History
```

## Phase 5

```text
Stock Opname
```

## Phase 6

```text
Realtime
Dashboard
Low Stock
Inventory Value
```

## Phase 7

```text
Polish
Error Handling
Loading State
Empty State
Offline/Connection Handling
```

---

# 32. Core Architecture

```text
Flutter UI
    ↓
Provider
    ↓
Repository
    ↓
Supabase Client
    ↓
┌──────────────────────────┐
│ Supabase                 │
│                          │
│ Auth                     │
│ PostgreSQL               │
│ RPC                      │
│ RLS                      │
│ Realtime                 │
└──────────────────────────┘
```

Stock mutation:

```text
Flutter
 ↓
RPC
 ↓
PostgreSQL Transaction
 ↓
Lock Product
 ↓
Validate
 ↓
Insert Ledger
 ↓
Update Stock
 ↓
Commit
 ↓
Realtime
 ↓
Other Devices
```