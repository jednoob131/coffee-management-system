<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User, entity.Bill, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isRole()) {
        response.sendRedirect(request.getContextPath() + "/index");
        return;
    }
    List<Bill> bills = (List<Bill>) request.getAttribute("bills");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/includes/head-common.jsp">
        <jsp:param name="title" value="Danh sách hóa đơn | Polly Coffee"/>
    </jsp:include>
</head>
<body class="flex min-h-screen">
<%
    request.setAttribute("activeNav", "admin_bills");
    request.setAttribute("pageHeading", "Danh sách hóa đơn");
    request.setAttribute("pageSubheading", "Tất cả hóa đơn trong hệ thống");
%>

<jsp:include page="/includes/dashboard-sidebar.jsp"/>

<div class="flex min-h-screen min-w-0 flex-1 flex-col">
    <jsp:include page="/includes/app-header.jsp"/>

    <main class="flex-1 overflow-auto p-8">
        <div id="page-header" class="mb-6 flex items-center justify-end">
            <input type="text" id="searchInput" placeholder="🔍 Tìm theo nhân viên..."
                   class="border-2 border-gray-200 rounded-xl px-4 py-2 text-sm font-bold outline-none focus:border-orange-400"
                   oninput="filterBills()">
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-orange-50 overflow-hidden">
            <table class="w-full">
                <thead class="bg-gray-50">
                <tr>
                    <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">#</th>
                    <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Nhân viên</th>
                    <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Thời gian</th>
                    <th class="text-right px-5 py-3 text-xs font-black text-gray-400 uppercase">Tổng tiền</th>
                    <th class="text-center px-5 py-3 text-xs font-black text-gray-400 uppercase">Chi tiết</th>
                </tr>
                </thead>
                <tbody id="billTable">
                <%
                    if (bills != null) {
                        for (Bill b : bills) {
                %>
                <tr class="border-b border-gray-50 hover:bg-orange-50 transition bill-row"
                    data-username="<%= b.getUsername() != null ? b.getUsername().toLowerCase() : "" %>">
                    <td class="px-5 py-4 font-black text-sm text-gray-400">#<%= b.getBillId() %></td>
                    <td class="px-5 py-4 font-black text-sm text-gray-800"><%= b.getUsername() %></td>
                    <td class="px-5 py-4 text-sm text-gray-500"><%= b.getCreatedDate() %></td>
                    <td class="px-5 py-4 text-right font-black text-[#FF9F1C]"><%= String.format("%,.0f", b.getTotalAmount()) %>đ</td>
                    <td class="px-5 py-4 text-center">
                        <button type="button"
                                onclick="openBillDetail(<%= b.getBillId() %>)"
                                class="text-xs font-black px-3 py-1.5 rounded-lg border-2 border-orange-300 text-orange-500 hover:bg-orange-50 transition">
                            Xem
                        </button>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Modal -->
    <div id="billDetailModal"
         class="fixed inset-0 z-50 hidden bg-black/40 px-4">
        <div class="w-full h-full flex items-center justify-center">
            <div id="billDetailCard"
                 class="w-full max-w-3xl rounded-2xl bg-white shadow-2xl border border-orange-100 overflow-hidden">

                <div class="flex items-center justify-between px-6 py-4 border-b border-orange-100 bg-orange-50">
                    <div>
                        <h2 class="text-lg font-black text-gray-800">Chi tiết hóa đơn</h2>
                        <p id="billMeta" class="text-sm text-gray-500">Đang tải...</p>
                    </div>
                    <button type="button"
                            onclick="closeBillDetail()"
                            class="h-10 w-10 rounded-full border border-orange-200 text-orange-500 hover:bg-orange-100 text-lg font-black">
                        ×
                    </button>
                </div>

                <div class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-5">
                        <div class="rounded-xl border border-orange-100 bg-orange-50 p-4">
                            <p class="text-xs font-black uppercase text-gray-400">Mã hóa đơn</p>
                            <p id="billIdText" class="mt-1 text-base font-black text-gray-800">-</p>
                        </div>

                        <div class="rounded-xl border border-orange-100 bg-orange-50 p-4">
                            <p class="text-xs font-black uppercase text-gray-400">Nhân viên</p>
                            <p id="billUserText" class="mt-1 text-base font-black text-gray-800">-</p>
                        </div>

                        <div class="rounded-xl border border-orange-100 bg-orange-50 p-4">
                            <p class="text-xs font-black uppercase text-gray-400">Thời gian</p>
                            <p id="billDateText" class="mt-1 text-base font-black text-gray-800">-</p>
                        </div>

                        <div class="rounded-xl border border-orange-100 bg-orange-50 p-4">
                            <p class="text-xs font-black uppercase text-gray-400">Tổng tiền</p>
                            <p id="billTotalText" class="mt-1 text-base font-black text-[#FF9F1C]">-</p>
                        </div>
                    </div>

                    <div class="rounded-2xl border border-orange-100 overflow-hidden">
                        <table class="w-full">
                            <thead class="bg-gray-50">
                            <tr>
                                <th class="text-left px-4 py-3 text-xs font-black text-gray-400 uppercase">Detail ID</th>
                                <th class="text-left px-4 py-3 text-xs font-black text-gray-400 uppercase">Drink ID</th>
                                <th class="text-center px-4 py-3 text-xs font-black text-gray-400 uppercase">Số lượng</th>
                                <th class="text-right px-4 py-3 text-xs font-black text-gray-400 uppercase">Đơn giá</th>
                                <th class="text-right px-4 py-3 text-xs font-black text-gray-400 uppercase">Thành tiền</th>
                            </tr>
                            </thead>
                            <tbody id="billDetailBody">
                            <tr>
                                <td colspan="5" class="px-4 py-6 text-center text-sm text-gray-400">
                                    Chưa có dữ liệu
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="mt-5 flex justify-end">
                        <button type="button"
                                onclick="closeBillDetail()"
                                class="px-4 py-2 rounded-xl bg-orange-500 text-white text-sm font-black hover:bg-orange-600 transition">
                            Đóng
                        </button>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script>
        function filterBills() {
            var q = document.getElementById('searchInput').value.toLowerCase();
            document.querySelectorAll('.bill-row').forEach(function (r) {
                r.style.display = r.dataset.username.includes(q) ? '' : 'none';
            });
        }

        function formatMoney(value) {
            var num = Number(value || 0);
            return num.toLocaleString('vi-VN') + 'đ';
        }

        function closeBillDetail() {
            var modal = document.getElementById('billDetailModal');
            modal.classList.add('hidden');
        }

        async function openBillDetail(billId) {
            var modal = document.getElementById('billDetailModal');
            var body = document.getElementById('billDetailBody');

            modal.classList.remove('hidden');

            document.getElementById('billIdText').textContent = '#' + billId;
            document.getElementById('billUserText').textContent = 'Đang tải...';
            document.getElementById('billDateText').textContent = 'Đang tải...';
            document.getElementById('billTotalText').textContent = 'Đang tải...';
            document.getElementById('billMeta').textContent = 'Đang tải chi tiết hóa đơn...';

            body.innerHTML =
                '<tr>' +
                    '<td colspan="5" class="px-4 py-6 text-center text-sm text-gray-400">' +
                        'Đang tải chi tiết hóa đơn...' +
                    '</td>' +
                '</tr>';

            try {
                var res = await fetch('<%= request.getContextPath() %>/admin/bills?ajax=1&billId=' + billId, {
                    method: 'GET',
                    headers: { 'Accept': 'application/json' }
                });

                if (!res.ok) {
                    throw new Error('Lỗi tải dữ liệu');
                }

                var data = await res.json();
                var bill = data.bill;
                var details = data.details || [];

                document.getElementById('billIdText').textContent = '#' + (bill.billId || billId);
                document.getElementById('billUserText').textContent = bill.username || '-';
                document.getElementById('billDateText').textContent = bill.createdDate || '-';
                document.getElementById('billTotalText').textContent = formatMoney(bill.totalAmount || 0);
                document.getElementById('billMeta').textContent = 'Danh sách món trong hóa đơn';

                if (details.length === 0) {
                    body.innerHTML =
                        '<tr>' +
                            '<td colspan="5" class="px-4 py-6 text-center text-sm text-gray-400">' +
                                'Hóa đơn này chưa có chi tiết sản phẩm' +
                            '</td>' +
                        '</tr>';
                    return;
                }

                var html = '';
                details.forEach(function (d) {
                    var quantity = d.quantity || 0;
                    var price = d.price || 0;
                    var lineTotal = quantity * price;

                    html +=
                        '<tr class="border-t border-gray-50 hover:bg-orange-50 transition">' +
                            '<td class="px-4 py-3 text-sm font-bold text-gray-700">' + (d.detailId || '') + '</td>' +
                            '<td class="px-4 py-3 text-sm font-bold text-gray-700">' + (d.drinkId || '') + '</td>' +
                            '<td class="px-4 py-3 text-sm text-center font-bold text-gray-700">' + quantity + '</td>' +
                            '<td class="px-4 py-3 text-sm text-right font-bold text-gray-700">' + formatMoney(price) + '</td>' +
                            '<td class="px-4 py-3 text-sm text-right font-black text-[#FF9F1C]">' + formatMoney(lineTotal) + '</td>' +
                        '</tr>';
                });

                body.innerHTML = html;

            } catch (e) {
                document.getElementById('billUserText').textContent = '-';
                document.getElementById('billDateText').textContent = '-';
                document.getElementById('billTotalText').textContent = '-';
                document.getElementById('billMeta').textContent = 'Có lỗi xảy ra';

                body.innerHTML =
                    '<tr>' +
                        '<td colspan="5" class="px-4 py-6 text-center text-sm text-red-500 font-bold">' +
                            'Không tải được chi tiết hóa đơn' +
                        '</td>' +
                    '</tr>';

                console.error(e);
            }
        }

        document.addEventListener('click', function (e) {
            var modal = document.getElementById('billDetailModal');
            if (e.target === modal) {
                closeBillDetail();
            }
        });

        window.addEventListener('DOMContentLoaded', function () {
            if (typeof gsap !== 'undefined') {
                var tl = gsap.timeline();

                tl.from('#page-header', {
                    y: 20,
                    opacity: 0,
                    duration: 0.6,
                    ease: 'power3.out'
                });

                tl.from('.bill-row', {
                    y: 15,
                    opacity: 0,
                    stagger: 0.05,
                    duration: 0.5,
                    ease: 'power2.out',
                    clearProps: "all"
                }, "-=0.3");
            }
        });
    </script>

    <jsp:include page="/includes/app-footer.jsp"/>
</div>

<jsp:include page="/includes/sidebar-gsap.jsp"/>
</body>
</html>