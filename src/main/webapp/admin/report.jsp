<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User, entity.Bill, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isRole()) { response.sendRedirect(request.getContextPath() + "/index"); return; }
    List<Bill> bills  = (List<Bill>) request.getAttribute("bills");
    double totalToday = request.getAttribute("totalToday") != null ? (double) request.getAttribute("totalToday") : 0;
    long   billToday  = request.getAttribute("billToday")  != null ? (long)   request.getAttribute("billToday")  : 0;
    double grandTotal = request.getAttribute("grandTotal") != null ? (double) request.getAttribute("grandTotal") : 0;
    double avgOrder   = request.getAttribute("avgOrder")   != null ? (double) request.getAttribute("avgOrder")   : 0;
    String chartLabelsJson = (String) request.getAttribute("chartLabelsJson");
    String chartDataJson   = (String) request.getAttribute("chartDataJson");
    String staffLabelsJson = (String) request.getAttribute("staffLabelsJson");
    String staffDataJson   = (String) request.getAttribute("staffDataJson");
    if (chartLabelsJson == null) chartLabelsJson = "[]";
    if (chartDataJson == null) chartDataJson = "[]";
    if (staffLabelsJson == null) staffLabelsJson = "[]";
    if (staffDataJson == null) staffDataJson = "[]";
    boolean staffChartEmpty = Boolean.TRUE.equals(request.getAttribute("staffChartEmpty"));
    int billCount = bills != null ? bills.size() : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/includes/head-common.jsp">
  <jsp:param name="title" value="Thống kê doanh thu | Polly Coffee"/>
</jsp:include>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<style>
  body { font-family: 'Plus Jakarta Sans', sans-serif; background: linear-gradient(145deg, #FFF8F0 0%, #FFF0E5 50%, #FDF6ED 100%); min-height: 100vh; }
  .kpi-card {
    position: relative; overflow: hidden;
    background: linear-gradient(135deg, #ffffff 0%, #FFFBF7 100%);
    border: 1px solid rgba(255, 159, 28, 0.15);
    box-shadow: 0 4px 24px rgba(255, 159, 28, 0.08), 0 1px 3px rgba(0,0,0,.04);
    transition: transform .2s, box-shadow .2s;
  }
  .kpi-card:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(255, 159, 28, 0.12); }
  .kpi-card::before {
    content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px;
    background: linear-gradient(90deg, #FF9F1C, #FFB84D, #FF9F1C);
    border-radius: 1rem 1rem 0 0;
  }
  .chart-card {
    background: #fff;
    border: 1px solid rgba(255, 159, 28, 0.12);
    box-shadow: 0 4px 20px rgba(0,0,0,.04);
  }
  .table-wrap { border-radius: 1rem; overflow: hidden; border: 1px solid rgba(0,0,0,.06); }
  .data-table thead th {
    background: linear-gradient(180deg, #FFF5EB 0%, #FFECD9 100%);
    color: #9a5a0a; font-size: 0.7rem; letter-spacing: .06em;
  }
  .data-table tbody tr { border-bottom: 1px solid #f3f4f6; transition: background .15s; }
  .data-table tbody tr:nth-child(even) { background: #FFFCFA; }
  .data-table tbody tr:hover { background: #FFF5EB; }
  .data-table tbody td { vertical-align: middle; }
  .badge-id {
    display: inline-flex; align-items: center; justify-content: center;
    min-width: 2.5rem; padding: 0.2rem 0.5rem;
    background: #f3f4f6; color: #6b7280; font-weight: 800; font-size: 0.75rem;
    border-radius: 0.5rem;
  }
  .amount-pill {
    display: inline-block; font-weight: 800; color: #c2410c;
    background: linear-gradient(135deg, #FFF7ED, #FFEDD5);
    padding: 0.35rem 0.75rem; border-radius: 9999px; font-size: 0.875rem;
  }
</style>
</head>
<body class="flex min-h-screen">
<% request.setAttribute("activeNav", "admin_report");
   request.setAttribute("pageHeading", "Thống kê doanh thu");
   request.setAttribute("pageSubheading", "Tổng quan theo thời gian & nhân viên — dữ liệu múi giờ Việt Nam"); %>
<jsp:include page="/includes/dashboard-sidebar.jsp"/>
<div class="flex min-h-screen min-w-0 flex-1 flex-col">
<jsp:include page="/includes/app-header.jsp"/>
<main class="flex-1 overflow-x-hidden overflow-y-auto p-6 md:p-8">
  <div class="mb-6 flex justify-end">
    <div class="flex items-center gap-2 text-xs font-bold text-amber-800/70 bg-white/80 px-3 py-2 rounded-xl border border-amber-100 shadow-sm">
      <svg class="w-4 h-4 text-[#FF9F1C]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
      <span>Báo cáo cập nhật khi tải trang</span>
    </div>
  </div>

  <!-- KPI -->
  <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-8">
    <div class="kpi-card rounded-2xl p-5 pt-6">
      <div class="flex justify-between items-start mb-3">
        <p class="text-[11px] font-extrabold text-gray-400 uppercase tracking-widest">Hôm nay</p>
        <span class="w-10 h-10 rounded-xl bg-orange-100 flex items-center justify-center text-[#FF9F1C]">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        </span>
      </div>
      <p class="text-2xl md:text-3xl font-black text-[#FF9F1C] tabular-nums"><%= String.format("%,.0f", totalToday) %><span class="text-lg">đ</span></p>
      <p class="text-xs font-bold text-gray-400 mt-2"><%= billToday %> hóa đơn trong ngày</p>
    </div>
    <div class="kpi-card rounded-2xl p-5 pt-6">
      <div class="flex justify-between items-start mb-3">
        <p class="text-[11px] font-extrabold text-gray-400 uppercase tracking-widest">Tổng tích lũy</p>
        <span class="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
        </span>
      </div>
      <p class="text-2xl md:text-3xl font-black text-gray-900 tabular-nums"><%= String.format("%,.0f", grandTotal) %><span class="text-lg text-gray-500">đ</span></p>
      <p class="text-xs font-bold text-gray-400 mt-2">Toàn bộ hóa đơn hệ thống</p>
    </div>
    <div class="kpi-card rounded-2xl p-5 pt-6">
      <div class="flex justify-between items-start mb-3">
        <p class="text-[11px] font-extrabold text-gray-400 uppercase tracking-widest">Số hóa đơn</p>
        <span class="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center text-amber-700">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
        </span>
      </div>
      <p class="text-2xl md:text-3xl font-black text-gray-900 tabular-nums"><%= billCount %></p>
      <p class="text-xs font-bold text-gray-400 mt-2">Tổng giao dịch đã ghi nhận</p>
    </div>
    <div class="kpi-card rounded-2xl p-5 pt-6">
      <div class="flex justify-between items-start mb-3">
        <p class="text-[11px] font-extrabold text-gray-400 uppercase tracking-widest">TB / hóa đơn</p>
        <span class="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center text-orange-700">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z"/></svg>
        </span>
      </div>
      <p class="text-2xl md:text-3xl font-black text-[#ea580c] tabular-nums"><%= String.format("%,.0f", avgOrder) %><span class="text-lg">đ</span></p>
      <p class="text-xs font-bold text-gray-400 mt-2">Giá trị trung bình mỗi bill</p>
    </div>
  </div>

  <!-- Charts -->
  <div class="grid grid-cols-1 lg:grid-cols-5 gap-6 mb-8">
    <div class="lg:col-span-3 chart-card rounded-2xl p-6">
      <div class="flex items-center justify-between mb-4 flex-wrap gap-2">
        <div>
          <h2 class="text-lg font-black text-gray-900">Doanh thu 7 ngày gần nhất</h2>
          <p class="text-xs font-semibold text-gray-400">Biểu đồ cột theo ngày (VN)</p>
        </div>
      </div>
      <div class="h-72 relative">
        <canvas id="revenueBarChart"></canvas>
      </div>
    </div>
    <div class="lg:col-span-2 chart-card rounded-2xl p-6 flex flex-col">
      <div class="mb-4">
        <h2 class="text-lg font-black text-gray-900">Theo nhân viên</h2>
        <p class="text-xs font-semibold text-gray-400">Tỷ lệ đóng góp doanh thu (top 6 + Khác)</p>
      </div>
      <div class="flex-1 min-h-[220px] flex items-center justify-center relative">
        <% if (staffChartEmpty) { %>
        <p class="text-sm font-bold text-gray-400 text-center px-4">Chưa có dữ liệu để vẽ biểu đồ</p>
        <% } else { %>
        <canvas id="staffDoughnutChart"></canvas>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Table -->
  <section class="table-wrap bg-white shadow-sm">
    <div class="px-5 py-4 border-b border-gray-100 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 bg-gradient-to-r from-white to-orange-50/30">
      <div>
        <h2 class="text-lg font-black text-gray-900">Chi tiết hóa đơn</h2>
        <p class="text-xs font-semibold text-gray-400 mt-0.5">Lọc nhanh theo khoảng ngày (trên trình duyệt)</p>
      </div>
      <div class="flex flex-wrap gap-2 items-center">
        <input type="date" id="dateFrom" class="border-2 border-gray-200 rounded-xl px-3 py-2 text-sm font-bold outline-none focus:border-[#FF9F1C] focus:ring-2 focus:ring-orange-100 bg-white">
        <span class="text-gray-300 font-black">→</span>
        <input type="date" id="dateTo" class="border-2 border-gray-200 rounded-xl px-3 py-2 text-sm font-bold outline-none focus:border-[#FF9F1C] focus:ring-2 focus:ring-orange-100 bg-white">
        <button type="button" onclick="filterByDate()" class="bg-[#FF9F1C] text-white font-black px-4 py-2 rounded-xl text-sm hover:brightness-105 shadow-md shadow-orange-200/50">Lọc</button>
        <button type="button" onclick="clearFilter()" class="border-2 border-gray-200 text-gray-600 font-black px-4 py-2 rounded-xl text-sm hover:bg-gray-50">Xóa lọc</button>
      </div>
    </div>
    <div class="overflow-x-auto">
      <table class="data-table w-full min-w-[640px]">
        <thead>
          <tr>
            <th class="text-left px-5 py-4 uppercase">Mã HĐ</th>
            <th class="text-left px-5 py-4 uppercase">Nhân viên</th>
            <th class="text-left px-5 py-4 uppercase">Thời gian</th>
            <th class="text-right px-5 py-4 uppercase">Tổng tiền</th>
          </tr>
        </thead>
        <tbody>
        <% if (bills != null && !bills.isEmpty()) {
            for (Bill b : bills) { %>
        <tr class="report-row"
            data-date="<%= b.getCreatedDate() != null ? b.getCreatedDate().toString().substring(0,10) : "" %>">
          <td class="px-5 py-3.5"><span class="badge-id">#<%= b.getBillId() %></span></td>
          <td class="px-5 py-3.5">
            <span class="font-bold text-gray-800 text-sm"><%= b.getUsername() %></span>
          </td>
          <td class="px-5 py-3.5 text-sm text-gray-500 font-medium tabular-nums"><%= b.getCreatedDate() %></td>
          <td class="px-5 py-3.5 text-right"><span class="amount-pill"><%= String.format("%,.0f", b.getTotalAmount()) %>đ</span></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="4" class="px-5 py-16 text-center">
          <div class="inline-flex flex-col items-center gap-2 text-gray-400">
            <svg class="w-12 h-12 opacity-40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
            <span class="font-bold">Chưa có hóa đơn nào</span>
          </div>
        </td></tr>
        <% } %>
        </tbody>
      </table>
    </div>
    <% if (bills != null && !bills.isEmpty()) { %>
    <div class="px-5 py-3 bg-gray-50/80 border-t border-gray-100 flex justify-end items-center gap-2 text-sm">
      <span class="font-bold text-gray-500">Cộng dồn (tất cả hàng đang hiển thị sau lọc):</span>
      <span id="filteredTotal" class="font-black text-[#FF9F1C] tabular-nums"><%= String.format("%,.0f", grandTotal) %>đ</span>
    </div>
    <% } %>
  </section>
</main>

<script>
(function () {
  const money = (v) => new Intl.NumberFormat('vi-VN').format(Math.round(v)) + 'đ';
  const orange = '#FF9F1C';
  const palette = ['#FF9F1C', '#F97316', '#EA580C', '#FB923C', '#FDBA74', '#FED7AA', '#94A3B8'];

  const labels = <%= chartLabelsJson %>;
  const dataVals = <%= chartDataJson %>;

  const ctxBar = document.getElementById('revenueBarChart');
  if (ctxBar && typeof Chart !== 'undefined') {
    new Chart(ctxBar, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Doanh thu',
          data: dataVals,
          backgroundColor: labels.map((_, i) => {
            const a = 0.35 + (i / Math.max(labels.length, 1)) * 0.45;
            return 'rgba(255, 159, 28, ' + a + ')';
          }),
          borderColor: orange,
          borderWidth: 2,
          borderRadius: 10,
          maxBarThickness: 48
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(15, 23, 42, 0.92)',
            padding: 12,
            titleFont: { weight: '700', size: 13 },
            bodyFont: { size: 13 },
            callbacks: { label: (c) => ' ' + money(c.parsed.y) }
          }
        },
        scales: {
          x: {
            grid: { display: false },
            ticks: { font: { weight: '600', size: 11 }, color: '#64748b' }
          },
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(0,0,0,.06)' },
            ticks: {
              font: { size: 10 },
              color: '#94a3b8',
              callback: (v) => (v >= 1e6 ? (v/1e6).toFixed(1) + 'M' : (v >= 1e3 ? (v/1e3).toFixed(0) + 'k' : v))
            }
          }
        }
      }
    });
  }

  <% if (!staffChartEmpty) { %>
  const sLabels = <%= staffLabelsJson %>;
  const sData = <%= staffDataJson %>;
  const ctxDon = document.getElementById('staffDoughnutChart');
  if (ctxDon && typeof Chart !== 'undefined') {
    new Chart(ctxDon, {
      type: 'doughnut',
      data: {
        labels: sLabels,
        datasets: [{
          data: sData,
          backgroundColor: sLabels.map((_, i) => palette[i % palette.length]),
          borderWidth: 2,
          borderColor: '#fff',
          hoverOffset: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '58%',
        plugins: {
          legend: {
            position: 'bottom',
            labels: { usePointStyle: true, padding: 14, font: { weight: '600', size: 11 } }
          },
          tooltip: {
            callbacks: {
              label: (c) => {
                const total = c.dataset.data.reduce((a, b) => a + b, 0);
                const pct = total ? ((c.parsed / total) * 100).toFixed(1) : 0;
                return ' ' + c.label + ': ' + money(c.parsed) + ' (' + pct + '%)';
              }
            }
          }
        }
      }
    });
  }
  <% } %>
})();

function rowAmount(el) {
  const pill = el.querySelector('.amount-pill');
  if (!pill) return 0;
  const t = pill.textContent.replace(/[^\d]/g, '');
  return parseInt(t, 10) || 0;
}

function filterByDate() {
  const from = document.getElementById('dateFrom').value;
  const to = document.getElementById('dateTo').value;
  let sum = 0;
  document.querySelectorAll('.report-row').forEach(r => {
    const d = r.dataset.date;
    let show = true;
    if (from && d < from) show = false;
    if (to && d > to) show = false;
    r.style.display = show ? '' : 'none';
    if (show) sum += rowAmount(r);
  });
  const ft = document.getElementById('filteredTotal');
  if (ft) ft.textContent = new Intl.NumberFormat('vi-VN').format(sum) + 'đ';
}

function clearFilter() {
  document.getElementById('dateFrom').value = '';
  document.getElementById('dateTo').value = '';
  let sum = 0;
  document.querySelectorAll('.report-row').forEach(r => {
    r.style.display = '';
    sum += rowAmount(r);
  });
  const ft = document.getElementById('filteredTotal');
  if (ft) ft.textContent = new Intl.NumberFormat('vi-VN').format(sum) + 'đ';
}
</script>
<jsp:include page="/includes/app-footer.jsp"/>
</div>
<jsp:include page="/includes/sidebar-gsap.jsp"/>
</body>
</html>
