# C4-MIRACLE

C4-MIRACLE adalah aplikasi pendisiplinan berbasis iOS dengan gamifikasi memancing. Pengguna menyelesaikan tugas dan membangun kebiasaan positif untuk mendapatkan reward dalam bentuk progres permainan.

---

# Project Structure

```
C4-MIRACLE
│
├── App
├── Core
├── Features
├── Shared
├── Resources
├── Targets
├── Assets.xcassets
└── README.md
```

---

# Git Workflow

Semua developer wajib mengikuti workflow berikut.

```
main
    │
    └── feature/<feature-name>
```

Flow development:

```
main
    ↓
Pull Latest
    ↓
Create Feature Branch
    ↓
Development
    ↓
Commit
    ↓
Push
    ↓
Pull Request
    ↓
Review
    ↓
Squash Merge
```

---

# Branch Naming

Gunakan format berikut.

```
feature/<feature-name>
bugfix/<issue-name>
hotfix/<issue-name>
release/<version>
```

Contoh

```
feature/login

feature/fishing-animation

bugfix/task-crash

hotfix/shield

release/1.0.0
```

---

# Commit Convention

Gunakan Conventional Commit.

```
feat:
fix:
refactor:
style:
docs:
test:
chore:
```

Contoh

```
feat: add fishing animation

fix: resolve task loading bug

refactor: simplify task service
```

---

# Pull Request

Setiap Pull Request harus menjelaskan:

- Apa yang dikerjakan
- Screenshot (jika UI berubah)
- Cara testing
- Scope perubahan

Checklist:

- [ ] Build Success
- [ ] Self Review
- [ ] No Warning
- [ ] No Merge Conflict

---

# Merge Rules

- Tidak boleh push langsung ke `main`
- Semua perubahan melalui Pull Request
- Menggunakan Squash Merge
- Minimal 1 approval
- Semua discussion harus selesai sebelum merge

---

# Developer Guidelines

## Architecture

Ikuti struktur project yang sudah ditentukan.

```
Core
Features
Shared
Resources
Targets
```

Jangan membuat folder baru tanpa diskusi.

---

## Feature

Semua feature berada pada folder `Features`.

Contoh

```
Features
├── Home
├── Tasks
├── Fishing
├── ScreenTime
├── Profile
└── Settings
```

Jangan mencampur logic antar feature.

---

## Core

Folder Core hanya berisi reusable code.

Contoh

- Components
- Services
- Managers
- Helpers
- Extensions
- DesignSystem

Core tidak boleh bergantung pada Feature.

---

## Shared

Shared digunakan untuk data yang digunakan lebih dari satu target.

Contoh

- Models
- Constants
- Extensions

---

# UI / UX Guidelines

Semua UI harus mengikuti Design System.

Jangan menggunakan nilai hardcoded untuk:

- Font
- Color
- Spacing
- Corner Radius
- Shadow
- Animation

Gunakan:

```
AppColors
AppTypography
AppSpacing
AppRadius
AppShadow
AppAnimation
```
atau nama yang akan disepakati kedepannya


---

## Components

Jika suatu UI digunakan lebih dari satu kali, pindahkan ke:

```
Core/Components
```

Jangan copy-paste view.

---

## Screen

Setiap screen hanya bertanggung jawab terhadap UI.

Business Logic berada di ViewModel.

---

## Consistency

Semua screen harus memiliki:

- Consistent Padding
- Consistent Typography
- Consistent Button Style
- Consistent Navigation

---

## Accessibility

Developer wajib mempertimbangkan:

- Dynamic Type
- Dark Mode
- VoiceOver
- Minimum Touch Area (44x44)

---

# Asset Guidelines

Asset dibagi menjadi dua kategori.

## Assets.xcassets

Digunakan hanya untuk:

- App Icon
- Accent Color
- UI Icons
- UI Images
- Colors

Jangan menyimpan sprite gameplay di sini.

---

## Resources

Digunakan untuk:

- Character
- Fish
- Boat
- Environment
- Effects
- Audio
- Fonts
- Localization

Struktur:

```
Resources
├── Assets
├── Audio
├── Fonts
└── Localization
```

---

## Asset Naming

Gunakan camelCase secara konsisten.

Contoh

```
fishSalmon

boatDefault

pierMain

characterIdle001
```

Hindari

```
gambar1

baru

fix

final
```

---

# AI Agent Guidelines

Developer bebas menggunakan AI Assistant (Cursor, Claude Code, GitHub Copilot, ChatGPT, dll).

AI harus:

- Mengikuti arsitektur project.
- Mengikuti Design System.
- Menggunakan Components yang sudah ada.
- Mengikuti naming convention.
- Membuat perubahan sekecil mungkin.
- Menjaga konsistensi struktur folder.

AI tidak boleh:

- Mengubah struktur project.
- Memindahkan file tanpa alasan.
- Melakukan refactor besar tanpa persetujuan.
- Menambah dependency tanpa diskusi.
- Mengubah Design System.
- Menghapus asset yang tidak berkaitan.

AI adalah alat bantu implementasi, bukan pengambil keputusan arsitektur.

---

# Future Targets

Project ini dirancang untuk mendukung beberapa target Apple.

- Main App
- Widget Extension
- Live Activity
- Screen Time Shield

Semua target harus mengikuti Design System dan menggunakan Shared Module bila memungkinkan.
