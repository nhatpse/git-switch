<div align="center">

# 🚀 Git Profile Manager - Ultimate Edition

**Trình quản lý đa tài khoản GitHub chuyên nghiệp dành cho Windows PowerShell**
<br>
*Switch Git Accounts & SSH Keys in seconds.*

[![Platform](https://img.shields.io/badge/Platform-Windows%20(PowerShell)-blue?style=for-the-badge&logo=windows)](https://microsoft.com/powershell)
[![Version](https://img.shields.io/badge/Version-2.0-cyan?style=for-the-badge)](https://github.com/nhatpse/git-switch)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 🌟 Tại sao bạn cần tool này?

Bạn là lập trình viên và gặp rắc rối khi dùng chung máy tính cho **Công việc (Work)** và **Dự án cá nhân (Personal)**?
- ❌ Lỡ commit code công ty bằng email cá nhân?
- ❌ Lỗi `Permission denied (publickey)` khi push code sang repo khác?
- ❌ Mệt mỏi vì phải gõ lệnh `git config` thủ công?

**Git Profile Manager** giải quyết tất cả chỉ với 1 file script duy nhất. Không cần Python, không cần cài đặt phức tạp.

## ✨ Tính năng nổi bật

* 🔥 **Run Directly:** Chạy trực tiếp từ GitHub, không cần clone, không cần cài đặt.
* 🔑 **SSH Auto-Gen:** Tự động tạo SSH Key, thêm vào `ssh-agent` và `config`.
* 📋 **Auto Clipboard:** Tự động copy Public Key và mở trang Settings của GitHub để bạn paste.
* 🔄 **Smart Switch:** Chuyển đổi profile cực nhanh. Tự động sửa Remote URL của dự án hiện tại để khớp với profile mới.
* 🛡️ **Isolated Environment:** Tách biệt hoàn toàn danh tính (Identity) giữa các tài khoản.
* 💎 **Luxurious UI:** Giao diện dòng lệnh đẹp mắt, dễ sử dụng.

---

## 🚀 Chạy ngay lập tức (Direct Run)

Bạn không cần tải về máy. Chỉ cần mở **PowerShell** (nhấn `Win + X` chọn PowerShell) và dán lệnh sau:

```powershell
iwr -useb [https://raw.githubusercontent.com/nhatpse/git-switch/main/git.ps1](https://raw.githubusercontent.com/nhatpse/git-switch/main/git.ps1) | iex