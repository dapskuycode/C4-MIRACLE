# Contribution Guidelines

## 1. Branch Strategy

* Semua pekerjaan **harus** dimulai dari branch `main` yang terbaru.
* Jangan pernah melakukan commit langsung ke `main`.
* Setiap fitur, bug fix, atau improvement harus dikerjakan pada branch terpisah.
* Setelah selesai, buat Pull Request untuk dilakukan review.

### Branch Naming

Gunakan format berikut:

```
feature/<feature-name>
bugfix/<issue-name>
hotfix/<issue-name>
release/<version>
```

Contoh:

```
feature/login
feature/profile
bugfix/login-crash
```

---

## 2. Commit Convention

Gunakan format **Conventional Commits**.

Format:

```
<type>: <description>
```

Jenis commit yang digunakan:

```
feat: add login screen
fix: resolve login crash
refactor: simplify network layer
docs: update README
test: add login tests
chore: update dependencies
style: format source code
```

### Aturan

* Gunakan bahasa Indonesia.
* Gunakan kalimat singkat dan jelas.
* Fokus pada perubahan utama dalam commit tersebut.
* Hindari commit seperti:

```
update
fix
done
123
test
```

---

## 3. Pull Request Guidelines

Setiap Pull Request harus berisi:

### Description

Jelaskan perubahan yang dilakukan.

### Screenshot

Wajib jika ada perubahan UI.

### Testing

Jelaskan bagaimana fitur diuji.

### Checklist

* [ ] Branch sudah di-update dari `main`
* [ ] Build berhasil
* [ ] Tidak menambah warning baru
* [ ] Sudah melakukan self review
* [ ] Perubahan hanya mencakup scope yang dikerjakan

### Review

Developer tidak diperbolehkan merge branch sendiri ke `main`.

Semua Pull Request harus melalui proses review dan approval.

---

## 4. Merge Rules

Repository menggunakan workflow Pull Request.

Aturan merge:

* Tidak boleh push langsung ke `main`.
* Semua perubahan harus melalui Pull Request.
* Pull Request harus di-review sebelum di-merge.
* Gunakan **Squash Merge** agar riwayat commit tetap bersih.
* Jika terdapat merge conflict, conflict harus diselesaikan sebelum proses merge.
* Setelah merge berhasil, branch feature dapat dihapus.

---

## 5. AI Agent Guidelines

Developer bebas menggunakan AI Assistant seperti ChatGPT, GitHub Copilot, Cursor, Claude Code, Windsurf, atau tools lainnya. Namun AI **tidak boleh** mengubah struktur proyek di luar kebutuhan task yang sedang dikerjakan.

### AI Agent harus:

* Mengikuti arsitektur dan coding style yang sudah ada.
* Menggunakan naming convention yang telah digunakan dalam project.
* Menambahkan file baru hanya jika memang diperlukan.
* Menempatkan file baru pada folder yang sesuai dengan struktur project.
* Menjaga konsistensi dependency injection, folder structure, dan module boundaries.
* Membuat perubahan sekecil mungkin sesuai scope task.
* Menghasilkan kode yang mudah dibaca dan mudah dipelihara.

### AI Agent tidak boleh:

* Memindahkan file tanpa alasan yang jelas.
* Mengubah struktur folder secara sepihak.
* Melakukan refactor besar ketika hanya diminta memperbaiki bug kecil.
* Mengganti arsitektur project tanpa persetujuan tim.
* Mengubah naming convention yang sudah digunakan.
* Menambahkan library atau dependency baru tanpa diskusi dan persetujuan tim.
* Menghapus kode, file, atau resource yang tidak berkaitan dengan task.

> **Principle:** AI adalah alat bantu implementasi, bukan pengambil keputusan arsitektur. Semua perubahan yang memengaruhi struktur project, arsitektur, atau pola pengembangan harus melalui persetujuan tim.

