# Word Chain Domino

เวอร์ชันพร้อมนำไปวางบน GitHub Pages

## โครงสร้าง

```text
word-chain-github-ready/
├── index.html
├── data/
│   ├── word-data.js
│   └── gloss-data.js
└── README.md
```

## วิธีใช้กับ GitHub Pages

1. อัปโหลด **index.html** และโฟลเดอร์ **data** เข้าไปใน repository เดียวกัน
2. ไปที่ **Settings → Pages**
3. เลือก **Deploy from a branch**
4. เลือก branch `main` และ folder `/ (root)`
5. Save แล้วเปิด URL ที่ GitHub Pages สร้างให้

> สำคัญ: ห้ามย้าย `word-data.js` หรือ `gloss-data.js` ออกจากโฟลเดอร์ `data` เพราะ `index.html` เรียกไฟล์ด้วย path `data/...`

## หมายเหตุ

- `index.html` คือหน้าเริ่มต้นของเกม จึงเปิดได้ทันทีเมื่อเข้า GitHub Pages
- Dictionary ถูกแยกออกจาก HTML เพื่อลดขนาดไฟล์หลัก
- UI, รูปภาพ, โหมดเกม, คะแนน และกติกาเดิมไม่ได้ถูกออกแบบใหม่ในขั้นตอนนี้
