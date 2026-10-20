# GIẢI TRÌNH KỸ THUẬT: TẠI SAO DÙNG COUNT(o.order_id) THAY VÌ COUNT(*)

### 1. Đoạn giải trình cốt lõi (Dưới 150 từ):
Trong SQL, `COUNT(*)` đếm tổng số dòng trong mỗi nhóm kết quả bất kể dòng đó chứa giá trị gì. Khi dùng `LEFT JOIN`, khách hàng chưa từng mua hàng (như Charlie) vẫn tạo ra một dòng kết quả trong đó các trường của bảng phụ `Orders` mang giá trị `NULL`. Do đó, nếu dùng `COUNT(*)`, hệ thống sẽ đếm luôn dòng `NULL` này và trả về `total_orders = 1`, làm sai lệch hoàn toàn dữ liệu và khiến khách hàng chưa mua bị mất quyền nhận Voucher 50%. Ngược lại, hàm `COUNT(o.order_id)` chỉ đếm các giá trị khác `NULL` trên cột `order_id`. Với khách hàng chưa mua, `o.order_id` là `NULL` nên hàm đếm bỏ qua và trả về chính xác `total_orders = 0`.

---

### 2. Bảng so sánh cơ chế hoạt động thực tế:

| Khách hàng | Cột `o.order_id` sau LEFT JOIN | Kết quả `COUNT(*)` (Sai lầm) | Kết quả `COUNT(o.order_id)` (Chính xác) | Đánh giá |
|:---|:---:|:---:|:---:|:---|
| **Alice** | `1001`, `1002` | **2** | **2** | Đúng |
| **Bob** | `1003` | **1** | **1** | Đúng |
| **Charlie** | `NULL` | **1** ❌ *(Đếm cả dòng NULL)* | **0** ✅ *(Bỏ qua giá trị NULL)* | **Chuẩn xác để tặng Voucher 50%** |
