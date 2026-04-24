<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User, entity.Drink, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    List<Drink> drinks       = (List<Drink>) request.getAttribute("drinks");
    String previewItems      = (String) request.getAttribute("previewItems");
    Double previewTotal      = (Double) request.getAttribute("previewTotal");
    String error             = (String) request.getAttribute("error");
    boolean showPreview      = previewItems != null && previewTotal != null;

    Object pendingCheckBillIdObj = request.getAttribute("pendingCheckBillId");
    String pendingCheckBillId = pendingCheckBillIdObj != null ? String.valueOf(pendingCheckBillIdObj) : "";

    Integer myBillsTotal       = (Integer) request.getAttribute("myBillsTotal");
    Double  myBillsAmount      = (Double) request.getAttribute("myBillsAmount");
    Integer myBillsTodayTotal  = (Integer) request.getAttribute("myBillsTodayTotal");
    Double  myBillsTodayAmount = (Double) request.getAttribute("myBillsTodayAmount");

    String selectedPaymentMethod = (String) request.getAttribute("selectedPaymentMethod");

    Object cashReceivedObj = request.getAttribute("cashReceived");
    Double cashReceivedVal = null;
    if (cashReceivedObj instanceof Double) {
        cashReceivedVal = (Double) cashReceivedObj;
    } else if (cashReceivedObj instanceof String) {
        try { cashReceivedVal = Double.parseDouble((String) cashReceivedObj); } catch (Exception ignored) {}
    }

    String payosCheckoutUrl = (String) request.getAttribute("payosCheckoutUrl");
    String payosQrText = (String) request.getAttribute("payosQrText");
    Object payosBillIdObj = request.getAttribute("payosBillId");
    String payosBillId = payosBillIdObj != null ? String.valueOf(payosBillIdObj) : "";
    boolean showPayosQr = payosQrText != null && !payosQrText.isEmpty();

    Boolean waitingObj = (Boolean) request.getAttribute("isWaitingBankPayment");
    boolean isWaitingBankPayment = waitingObj != null && waitingObj;

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) {
        session.removeAttribute("flashSuccess");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/includes/head-common.jsp">
  <jsp:param name="title" value="Tạo hóa đơn | Polly Coffee"/>
</jsp:include>

<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

<style>
  .drink-row { transition: background .15s; }
  .drink-row:hover { background: #FFF8F0; }

  .qty-btn {
    width: 28px;
    height: 28px;
    border-radius: 8px;
    border: 2px solid #e5e7eb;
    background: white;
    font-weight: 800;
    font-size: 1rem;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all .15s;
  }

  .qty-btn:hover {
    border-color: #FF9F1C;
    color: #FF9F1C;
  }

  .qty-input {
    width: 48px;
    text-align: center;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    padding: 4px;
    font-weight: 800;
    font-size: .85rem;
    outline: none;
  }

  .qty-input:focus {
    border-color: #FF9F1C;
  }

  .pay-card {
    border: 2px solid #f3f4f6;
    border-radius: 14px;
    padding: 14px;
    transition: .2s ease;
    cursor: pointer;
  }

  .pay-card.active {
    border-color: #FF9F1C;
    background: #FFF7ED;
    box-shadow: 0 10px 25px rgba(255,159,28,.12);
  }

  .money-box {
    background: #fff7ed;
    border: 1px solid #fed7aa;
    border-radius: 14px;
    padding: 14px;
  }

  .cash-stepper {
    display: flex;
    align-items: stretch;
    gap: 8px;
  }

  .cash-step-btn {
    width: 46px;
    min-width: 46px;
    border-radius: 12px;
    border: 2px solid #fed7aa;
    background: #fff7ed;
    color: #c2410c;
    font-weight: 900;
    font-size: 22px;
    cursor: pointer;
    transition: .15s;
  }

  .cash-step-btn:hover {
    border-color: #FF9F1C;
    color: #FF9F1C;
    background: #ffffff;
  }

  .qr-box {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    border-radius: 18px;
    padding: 16px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 292px;
    min-width: 292px;
  }

  .qr-box #bankQrCanvas img,
  .qr-box #bankQrCanvas canvas {
    width: 260px !important;
    height: 260px !important;
    display: block;
  }

  .pay-wait-btn {
    width: 100%;
    background: #f59e0b;
    color: white;
    font-weight: 900;
    padding: 14px;
    border-radius: 14px;
    border: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    cursor: not-allowed;
    opacity: .95;
  }

  .spinner {
    width: 18px;
    height: 18px;
    border: 3px solid rgba(255,255,255,.35);
    border-top-color: #fff;
    border-radius: 999px;
    animation: spin .8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
</head>
<body class="flex min-h-screen">
<%
   request.setAttribute("activeNav", "staff_bills");
   request.setAttribute("pageHeading", "Tạo hóa đơn");
   request.setAttribute("pageSubheading", "Chọn món, xác nhận và thanh toán");
%>

<jsp:include page="/includes/dashboard-sidebar.jsp"/>

<div class="flex min-h-screen min-w-0 flex-1 flex-col">
<jsp:include page="/includes/app-header.jsp"/>

<main class="flex-1 overflow-auto p-8">

  <% if (flashSuccess != null) { %>
    <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-xl text-sm font-bold text-green-600">
      ✅ <%= flashSuccess %>
    </div>
  <% } %>

  <% if (error != null) { %>
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-xl text-sm font-bold text-red-500">
      ⚠ <%= error %>
    </div>
  <% } %>

  <% if (pendingCheckBillId != null && !pendingCheckBillId.isEmpty()) { %>
    <div class="mb-4 p-3 bg-amber-50 border border-amber-200 rounded-xl text-sm font-bold text-amber-600">
      ⏳ Đang xác nhận thanh toán online cho hóa đơn #<%= pendingCheckBillId %>...
    </div>
  <% } %>

  <div class="grid grid-cols-2 gap-4 mb-6">
    <div class="bg-white rounded-2xl p-5 shadow-sm border border-orange-50">
      <p class="text-xs font-black text-gray-400 uppercase tracking-wider mb-2">Tổng hóa đơn của tôi</p>
      <p class="text-2xl font-black text-[#FF9F1C]"><%= myBillsTotal != null ? myBillsTotal : 0 %></p>
      <p class="text-xs text-gray-400 mt-1">
        Tổng tiền:
        <span class="font-bold text-gray-700"><%= myBillsAmount != null ? String.format("%,.0f", myBillsAmount) : "0" %>đ</span>
      </p>
    </div>

    <div class="bg-white rounded-2xl p-5 shadow-sm border border-orange-50">
      <p class="text-xs font-black text-gray-400 uppercase tracking-wider mb-2">Hóa đơn hôm nay</p>
      <p class="text-2xl font-black text-[#FF9F1C]"><%= myBillsTodayTotal != null ? myBillsTodayTotal : 0 %></p>
      <p class="text-xs text-gray-400 mt-1">
        Tổng tiền:
        <span class="font-bold text-gray-700"><%= myBillsTodayAmount != null ? String.format("%,.0f", myBillsTodayAmount) : "0" %>đ</span>
      </p>
    </div>
  </div>

  <% if (showPreview) { %>
    <div class="bg-white rounded-2xl shadow-sm border border-orange-100 p-6 max-w-4xl mx-auto">
      <h3 class="font-black text-lg text-gray-900 mb-4">📋 Xác nhận hóa đơn</h3>

      <table class="w-full text-sm mb-5">
        <thead>
          <tr class="border-b border-gray-100">
            <th class="text-left py-2 font-black text-gray-400 text-xs uppercase">Món</th>
            <th class="text-center py-2 font-black text-gray-400 text-xs uppercase">SL</th>
            <th class="text-right py-2 font-black text-gray-400 text-xs uppercase">Đơn giá</th>
            <th class="text-right py-2 font-black text-gray-400 text-xs uppercase">Thành tiền</th>
          </tr>
        </thead>
        <tbody>
        <%
          for (String item : previewItems.split("\\|")) {
            if (item.isEmpty()) continue;
            String[] p = item.split(":");
            int qty = Integer.parseInt(p[1]);
            double price = Double.parseDouble(p[2]);
            String name = p[3];
            double sub = qty * price;
        %>
          <tr class="border-b border-gray-50">
            <td class="py-3 font-bold text-gray-800"><%= name %></td>
            <td class="py-3 text-center font-bold text-gray-600"><%= qty %></td>
            <td class="py-3 text-right text-gray-600"><%= String.format("%,.0f", price) %>đ</td>
            <td class="py-3 text-right font-black text-gray-900"><%= String.format("%,.0f", sub) %>đ</td>
          </tr>
        <% } %>
        </tbody>
      </table>

      <div class="flex items-center justify-between p-4 bg-orange-50 rounded-xl mb-5">
        <span class="font-black text-gray-700">Tổng cộng</span>
        <span class="text-2xl font-black text-[#FF9F1C]" id="preview-total-text">
          <%= String.format("%,.0f", previewTotal) %>đ
        </span>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <form action="<%= request.getContextPath() %>/staff/bills" method="post" class="space-y-4" id="confirmForm">
          <input type="hidden" name="action" value="confirm">
          <input type="hidden" name="previewItems" value="<%= previewItems %>">
          <input type="hidden" name="previewTotal" value="<%= previewTotal %>">
          <input type="hidden" id="previewTotalValue" value="<%= previewTotal %>">

          <div>
            <p class="text-xs font-black text-gray-400 uppercase tracking-wider mb-2">Phương thức thanh toán</p>

            <div class="grid grid-cols-2 gap-3">
              <label class="pay-card <%= !"bank".equals(selectedPaymentMethod) ? "active" : "" %>">
                <input type="radio" name="paymentMethod" value="cash"
                       <%= !"bank".equals(selectedPaymentMethod) ? "checked" : "" %>
                       <%= isWaitingBankPayment ? "disabled" : "" %>
                       onchange="togglePaymentMethod()">
                <span class="ml-2 font-black text-gray-800">💵 Tiền mặt</span>
              </label>

              <label class="pay-card <%= "bank".equals(selectedPaymentMethod) ? "active" : "" %>">
                <input type="radio" name="paymentMethod" value="bank"
                       <%= "bank".equals(selectedPaymentMethod) ? "checked" : "" %>
                       <%= isWaitingBankPayment ? "disabled" : "" %>
                       onchange="togglePaymentMethod()">
                <span class="ml-2 font-black text-gray-800">🏦 Chuyển khoản</span>
              </label>
            </div>
          </div>

          <div id="cashSection" class="<%= "bank".equals(selectedPaymentMethod) ? "hidden" : "" %>">
            <div class="money-box mb-3">
              <label class="block text-xs font-black text-gray-400 uppercase mb-2">Số tiền khách đưa</label>

              <div class="cash-stepper">
                <button type="button" class="cash-step-btn" onclick="changeCash(-1000)">−</button>
                <input type="number"
                       step="1000"
                       min="0"
                       name="cashReceived"
                       id="cashReceived"
                       value="<%= cashReceivedVal != null ? String.format("%.0f", cashReceivedVal) : "" %>"
                       oninput="normalizeCashValue(); calcChange();"
                       placeholder="Ví dụ: 50000"
                       class="w-full border-2 border-orange-100 rounded-xl px-4 py-3 outline-none focus:border-[#FF9F1C] font-bold text-gray-800"
                       <%= isWaitingBankPayment ? "disabled" : "" %>>
                <button type="button" class="cash-step-btn" onclick="changeCash(1000)">+</button>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div class="money-box">
                <p class="text-xs font-black text-gray-400 uppercase mb-1">Tổng bill</p>
                <p class="font-black text-gray-900" id="cashTotalDisplay"><%= String.format("%,.0f", previewTotal) %>đ</p>
              </div>
              <div class="money-box">
                <p class="text-xs font-black text-gray-400 uppercase mb-1">Tiền thối</p>
                <p class="font-black text-[#FF9F1C]" id="changeDisplay">0đ</p>
              </div>
            </div>
          </div>

          <div id="bankSection" class="<%= "bank".equals(selectedPaymentMethod) ? "" : "hidden" %>">
            <% if (showPayosQr) { %>
              <div class="bg-white border-2 border-orange-100 rounded-2xl p-5 shadow-sm">
                <p class="text-xs font-black text-gray-400 uppercase mb-1">Thanh toán online</p>
                <p class="font-bold text-gray-800 mb-3">payOS QR</p>

                <div class="flex flex-col items-center justify-center text-center">
                  <div class="qr-box">
                    <div id="bankQrCanvas"></div>
                  </div>

                  <p class="text-sm text-gray-600 mt-4">
                    Hóa đơn #<%= payosBillId %> đang chờ thanh toán.
                  </p>

                  <p class="text-sm text-gray-500 mt-1">
                    Khách mở app ngân hàng và quét mã VietQR này để thanh toán.
                  </p>

                  <% if (payosCheckoutUrl != null && !payosCheckoutUrl.isEmpty()) { %>
                    <a href="<%= payosCheckoutUrl %>" target="_blank"
                       class="mt-4 inline-flex items-center justify-center px-4 py-2 rounded-xl border-2 border-orange-200 text-orange-500 font-black hover:bg-orange-50">
                      Mở trang payOS
                    </a>
                  <% } %>
                </div>
              </div>
            <% } else { %>
              <div class="money-box">
                <p class="text-xs font-black text-gray-400 uppercase mb-1">Thanh toán online</p>
                <p class="font-bold text-gray-800">payOS QR</p>
                <p class="text-sm text-gray-500 mt-2">
                  Sau khi bấm xác nhận, hệ thống sẽ tạo mã QR thanh toán ngay tại đây.
                </p>
              </div>
            <% } %>
          </div>

          <% if (isWaitingBankPayment) { %>
            <button type="button" class="pay-wait-btn" disabled>
              <span class="spinner"></span>
              Đang chờ thanh toán...
            </button>
          <% } else { %>
            <button type="submit"
                    id="confirmBtn"
                    class="w-full bg-[#FF9F1C] text-white font-black py-3 rounded-xl hover:opacity-90">
              ✅ Xác nhận thanh toán
            </button>
          <% } %>
        </form>

        <div class="bg-[#FFF8F0] rounded-2xl border border-orange-100 p-5">
          <h4 class="font-black text-gray-800 mb-3">Gợi ý thao tác</h4>
          <ul class="space-y-3 text-sm text-gray-600">
            <li><span class="font-black text-gray-800">Tiền mặt:</span> dùng nút − / + để tăng giảm mỗi lần 1.000đ, hệ thống tự tính tiền thối.</li>
            <li><span class="font-black text-gray-800">Chuyển khoản:</span> bấm xác nhận để tạo mã VietQR ngay trong trang này.</li>
            <li><span class="font-black text-gray-800">Tự động:</span> khi khách thanh toán xong, bill sẽ được hoàn tất và cộng vào tổng bill nhân viên.</li>
          </ul>

          <a href="<%= request.getContextPath() %>/staff/bills"
             class="mt-5 inline-flex items-center justify-center w-full border-2 border-gray-200 text-gray-500 font-black py-3 rounded-xl hover:border-orange-300 hover:text-orange-400 <%= isWaitingBankPayment ? "pointer-events-none opacity-50" : "" %>">
            ✏ Chỉnh sửa đơn
          </a>
        </div>
      </div>
    </div>

  <% } else { %>
    <form action="<%= request.getContextPath() %>/staff/bills" method="post" id="orderForm">
      <input type="hidden" name="action" value="preview">

      <div class="bg-white rounded-2xl shadow-sm border border-orange-50 overflow-hidden mb-6">
        <div class="p-4 border-b border-gray-100 flex items-center justify-between">
          <h3 class="font-black text-gray-800">Danh sách đồ uống</h3>
          <span class="text-xs font-bold text-gray-400">Nhập số lượng = 0 để bỏ qua</span>
        </div>

        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Tên món</th>
              <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Danh mục</th>
              <th class="text-right px-5 py-3 text-xs font-black text-gray-400 uppercase">Đơn giá</th>
              <th class="text-center px-5 py-3 text-xs font-black text-gray-400 uppercase">Số lượng</th>
              <th class="text-right px-5 py-3 text-xs font-black text-gray-400 uppercase">Thành tiền</th>
            </tr>
          </thead>
          <tbody>
          <% if (drinks != null) for (Drink d : drinks) { %>
            <tr class="drink-row border-b border-gray-50" id="row-<%= d.getDrinkId() %>">
              <td class="px-5 py-4">
                <input type="hidden" name="drinkId" value="<%= d.getDrinkId() %>">
                <p class="font-black text-gray-800 text-sm"><%= d.getDrinkName() %></p>
              </td>
              <td class="px-5 py-4">
                <span class="text-xs font-bold text-gray-400 bg-gray-100 px-2 py-1 rounded-lg"><%= d.getCategory() %></span>
              </td>
              <td class="px-5 py-4 text-right font-bold text-gray-700 text-sm"><%= String.format("%,.0f", d.getPrice()) %>đ</td>
              <td class="px-5 py-4">
                <div class="flex items-center justify-center gap-2">
                  <button type="button" class="qty-btn" onclick="changeQty(<%= d.getDrinkId() %>, -1)">−</button>
                  <input type="number" name="quantity" id="qty-<%= d.getDrinkId() %>"
                         class="qty-input" value="0" min="0" max="99"
                         data-price="<%= d.getPrice() %>" data-id="<%= d.getDrinkId() %>"
                         oninput="updateRow(<%= d.getDrinkId() %>)">
                  <button type="button" class="qty-btn" onclick="changeQty(<%= d.getDrinkId() %>, 1)">+</button>
                </div>
              </td>
              <td class="px-5 py-4 text-right font-black text-gray-900 text-sm" id="sub-<%= d.getDrinkId() %>">0đ</td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>

      <div class="bg-white rounded-2xl shadow-sm border border-orange-100 p-5 flex items-center justify-between">
        <div>
          <p class="text-xs font-bold text-gray-400 uppercase tracking-wider">Tổng cộng</p>
          <p class="text-3xl font-black text-[#FF9F1C] mt-1" id="grand-total">0đ</p>
        </div>
        <button type="submit"
                class="bg-[#FF9F1C] text-white font-black px-8 py-4 rounded-xl shadow-lg shadow-orange-200 hover:opacity-90 flex items-center gap-2">
          Xem xác nhận
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
            <path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>
          </svg>
        </button>
      </div>
    </form>
  <% } %>
</main>

<script>
function changeQty(id, delta) {
  const input = document.getElementById('qty-' + id);
  let val = parseInt(input.value || 0) + delta;
  if (val < 0) val = 0;
  if (val > 99) val = 99;
  input.value = val;
  updateRow(id);
}

function updateRow(id) {
  const input = document.getElementById('qty-' + id);
  const qty = parseInt(input.value) || 0;
  const price = parseFloat(input.dataset.price);
  const sub = qty * price;
  document.getElementById('sub-' + id).textContent = sub > 0 ? sub.toLocaleString('vi-VN') + 'đ' : '0đ';
  updateTotal();
}

function updateTotal() {
  let total = 0;
  document.querySelectorAll('.qty-input').forEach(input => {
    total += (parseInt(input.value) || 0) * parseFloat(input.dataset.price);
  });
  document.getElementById('grand-total').textContent = total > 0 ? total.toLocaleString('vi-VN') + 'đ' : '0đ';
}

function togglePaymentMethod() {
  const method = document.querySelector('input[name="paymentMethod"]:checked')?.value;
  const cashSection = document.getElementById('cashSection');
  const bankSection = document.getElementById('bankSection');
  const cards = document.querySelectorAll('.pay-card');

  cards.forEach(card => card.classList.remove('active'));
  document.querySelectorAll('input[name="paymentMethod"]').forEach(input => {
    if (input.checked) input.closest('.pay-card').classList.add('active');
  });

  if (method === 'cash') {
    if (cashSection) cashSection.classList.remove('hidden');
    if (bankSection) bankSection.classList.add('hidden');
  } else {
    if (cashSection) cashSection.classList.add('hidden');
    if (bankSection) bankSection.classList.remove('hidden');
  }

  calcChange();
}

function normalizeCashValue() {
  const cashInput = document.getElementById('cashReceived');
  if (!cashInput) return;

  let value = parseFloat(cashInput.value);

  if (isNaN(value) || value < 0) {
    cashInput.value = '';
  }
}

function changeCash(delta) {
  const cashInput = document.getElementById('cashReceived');
  if (!cashInput) return;

  let value = parseInt(cashInput.value || 0);
  if (isNaN(value)) value = 0;

  value += delta;
  if (value < 0) value = 0;

  value = Math.round(value / 1000) * 1000;
  cashInput.value = value === 0 ? '' : value;
  calcChange();
}

function calcChange() {
  const totalInput = document.getElementById('previewTotalValue');
  const cashInput = document.getElementById('cashReceived');
  const changeDisplay = document.getElementById('changeDisplay');
  if (!totalInput || !cashInput || !changeDisplay) return;

  const total = parseFloat(totalInput.value) || 0;
  const cash = parseFloat(cashInput.value) || 0;
  const change = cash - total;

  if (cash <= 0) {
    changeDisplay.textContent = '0đ';
    changeDisplay.classList.remove('text-red-500');
    changeDisplay.classList.add('text-[#FF9F1C]');
    return;
  }

  if (change < 0) {
    changeDisplay.textContent = 'Thiếu ' + Math.abs(change).toLocaleString('vi-VN') + 'đ';
    changeDisplay.classList.remove('text-[#FF9F1C]');
    changeDisplay.classList.add('text-red-500');
  } else {
    changeDisplay.textContent = change.toLocaleString('vi-VN') + 'đ';
    changeDisplay.classList.remove('text-red-500');
    changeDisplay.classList.add('text-[#FF9F1C]');
  }
}

function startPaymentPolling(billId) {
  if (!billId) return;

  const timer = setInterval(async function () {
    try {
      const response = await fetch('<%= request.getContextPath() %>/staff/bills/check-payment?billId=' + billId, {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
      });

      const data = await response.json();

      if (data.success && data.paid) {
        clearInterval(timer);
        setTimeout(function () {
          window.location.href = '<%= request.getContextPath() %>/staff/bills?billId=' + billId;
        }, 800);
      }
    } catch (e) {
      console.log('Polling payment error:', e);
    }
  }, 3000);
}

document.addEventListener('DOMContentLoaded', function () {
  togglePaymentMethod();
  calcChange();

  const qrText = `<%= payosQrText != null ? payosQrText : "" %>`;
  const qrBox = document.getElementById('bankQrCanvas');

  if (qrText && qrBox) {
    qrBox.innerHTML = '';
    new QRCode(qrBox, {
      text: qrText,
      width: 260,
      height: 260,
      correctLevel: QRCode.CorrectLevel.M
    });
  }

  <% if (pendingCheckBillId != null && !pendingCheckBillId.isEmpty()) { %>
    startPaymentPolling("<%= pendingCheckBillId %>");
  <% } %>
});
</script>

<jsp:include page="/includes/app-footer.jsp"/>
</div>
<jsp:include page="/includes/sidebar-gsap.jsp"/>
</body>
</html>