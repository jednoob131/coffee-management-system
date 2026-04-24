<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    boolean isAdmin = user.isRole();

    // Lấy data từ IndexServlet
    double totalToday  = request.getAttribute("totalToday")  != null ? (double) request.getAttribute("totalToday")  : 0;
    long   billToday   = request.getAttribute("billToday")   != null ? (long)   request.getAttribute("billToday")   : 0;
    long   totalDrinks = request.getAttribute("totalDrinks") != null ? (long)   request.getAttribute("totalDrinks") : 0;
    long   totalStaff  = request.getAttribute("totalStaff")  != null ? (long)   request.getAttribute("totalStaff")  : 0;
    int    myBills     = request.getAttribute("myBills")     != null ? (int)    request.getAttribute("myBills")     : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/includes/head-common.jsp">
  <jsp:param name="title" value="3D Dashboard | Polly Coffee"/>
</jsp:include>
<!-- Three.js & OrbitControls -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>

<style>
  body {
    font-family: 'Plus Jakarta Sans', sans-serif;
    background: #fdfbf7;
    overflow: hidden;
  }

  /* HIỆU ỨNG GLASSMORPHISM */
  .glass-panel {
    background: rgba(255, 255, 255, 0.85);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid rgba(255, 255, 255, 1);
    box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.08);
  }

  .stat-badge { position: relative; overflow: hidden; }
  .stat-badge::before {
    content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px;
    background: var(--theme-color); border-radius: 4px 0 0 4px;
  }

  /* THẺ CÓ THỂ KÉO THẢ */
  .branch-card {
    position: absolute;
    width: 260px;
    z-index: 10;
    display: flex; flex-direction: column;
    transition: box-shadow 0.2s, border-color 0.2s; /* Bỏ transition transform/left/top để kéo ko bị lag */
    will-change: left, top;
  }
  .branch-card:hover {
    border-color: rgba(255, 159, 28, 0.5);
    box-shadow: 0 15px 35px -5px rgba(255, 159, 28, 0.25);
  }

  /* THANH NẮM ĐỂ KÉO */
  .drag-handle {
    cursor: grab;
    padding: 12px 16px 8px 16px;
    user-select: none;
  }
  .drag-handle:active { cursor: grabbing; }

  /* ĐƯỜNG NỐI SVG */
  .flow-line {
    stroke-width: 2px;
    stroke-dasharray: 6 6; /* Nét đứt công nghệ */
    filter: drop-shadow(0 0 3px currentColor);
    opacity: 0.6;
    transition: opacity 0.3s;
  }
  .branch-card:hover ~ #svg-layer .flow-line,
  .branch-card:active ~ #svg-layer .flow-line {
    opacity: 1;
    stroke-dasharray: none; /* Rõ nét khi tương tác */
  }

  /* LAYOUT LỚP */
  #main-container { position: relative; width: 100%; height: 100%; overflow: hidden; }
  #canvas-container { position: absolute; inset: 0; z-index: 1; cursor: grab; }
  #canvas-container:active { cursor: grabbing; }
  #svg-layer { position: absolute; inset: 0; z-index: 2; pointer-events: none; width: 100%; height: 100%; }
  #ui-layer { position: absolute; inset: 0; z-index: 5; pointer-events: none; }
  .pointer-auto { pointer-events: auto; }
</style>
</head>
<body class="flex h-screen w-screen">
<% request.setAttribute("activeNav", "dashboard"); %>
<jsp:include page="/includes/dashboard-sidebar.jsp"/>

<div class="flex min-h-0 min-w-0 flex-1 flex-col">
<!-- ═══ MAIN AREA ═══ -->
<main class="min-h-0 flex-1" id="main-container">

  <!-- Canvas chứa model 3D -->
  <div id="canvas-container" title="Nhấn giữ và kéo để xoay cốc. Lăn chuột để zoom."></div>

  <!-- Lớp vẽ tia nối (Nằm dưới UI layer) -->
  <svg id="svg-layer">
    <!-- Đường path sẽ được tạo bằng Javascript -->
  </svg>

  <!-- Lớp phủ UI chứa các Card -->
  <div id="ui-layer">

    <!-- Header thông báo -->
    <div class="absolute top-6 left-8 pointer-events-auto z-20" id="greeting-text">
      <h2 class="text-3xl font-black text-gray-800 drop-shadow-sm">
        Xin chào, <span class="text-[#FF9F1C]"><%= user.getFullname() %></span> 👋
      </h2>
      <p class="text-sm text-gray-500 font-medium mt-1 bg-white/50 inline-block px-3 py-1 rounded-full border border-white">
        Nhấn giữ thẻ và kéo thả tự do để sắp xếp giao diện.
      </p>
    </div>

    <!-- KHU VỰC THÔNG SỐ ĐẦU TRANG -->
    <div class="absolute top-6 right-8 flex gap-4 pointer-events-auto z-20">
      <% if (isAdmin) { %>
      <div class="glass-panel rounded-2xl p-4 flex items-center gap-4 stat-badge min-w-[200px]" style="--theme-color: #FF9F1C;">
        <div>
          <p class="text-[10px] font-bold text-gray-500 uppercase tracking-widest pl-2">Doanh thu</p>
          <p class="text-lg font-black text-gray-800 pl-2 mt-0.5">
            <%= totalToday > 0 ? String.format("%,.0f", totalToday) + "đ" : "0đ" %>
          </p>
        </div>
        <div class="w-10 h-10 ml-auto rounded-full bg-orange-50 flex items-center justify-center text-orange-500">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" x2="12" y1="1" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
        </div>
      </div>

      <div class="glass-panel rounded-2xl p-4 flex items-center gap-4 stat-badge min-w-[160px]" style="--theme-color: #3b82f6;">
        <div>
          <p class="text-[10px] font-bold text-gray-500 uppercase tracking-widest pl-2">Hóa đơn</p>
          <p class="text-lg font-black text-gray-800 pl-2 mt-0.5"><%= billToday %></p>
        </div>
        <div class="w-10 h-10 ml-auto rounded-full bg-blue-50 flex items-center justify-center text-blue-500">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
        </div>
      </div>
      <% } else { %>
      <div class="glass-panel rounded-2xl p-4 flex items-center gap-4 stat-badge min-w-[160px]" style="--theme-color: #FF9F1C;">
        <div>
          <p class="text-[10px] font-bold text-gray-500 uppercase tracking-widest pl-2">Hóa đơn tôi</p>
          <p class="text-lg font-black text-gray-800 pl-2 mt-0.5"><%= myBills %></p>
        </div>
      </div>
      <div class="glass-panel rounded-2xl p-4 flex items-center gap-4 stat-badge min-w-[160px]" style="--theme-color: #22c55e;">
        <div>
          <p class="text-[10px] font-bold text-gray-500 uppercase tracking-widest pl-2">Đồ uống</p>
          <p class="text-lg font-black text-gray-800 pl-2 mt-0.5"><%= totalDrinks %></p>
        </div>
      </div>
      <% } %>
    </div>

    <!-- ═══ CÁC THẺ KÉO THẢ (DRAGGABLE CARDS) ═══ -->
    <% if (isAdmin) { %>

    <div class="glass-panel branch-card pointer-auto rounded-2xl" data-line-color="#FF9F1C" style="left: 8%; top: 30%;">
      <div class="drag-handle flex items-center gap-2 border-b border-gray-100/60 pb-2">
        <div class="w-2.5 h-2.5 rounded-full bg-[#FF9F1C] shadow-[0_0_8px_#FF9F1C]"></div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest flex-1">Di chuyển</p>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/></svg>
      </div>
      <div class="p-5 pt-3">
        <h3 class="font-black text-gray-800 text-lg leading-tight mb-2">Quản lý Đồ uống</h3>
        <p class="text-xs text-gray-500 mb-4">Hiện có <strong class="text-[#FF9F1C]"><%= totalDrinks %></strong> món trong menu. Cập nhật giá và trạng thái.</p>
        <a href="<%= request.getContextPath() %>/admin/drinks" class="block text-center w-full py-2.5 bg-orange-50 rounded-xl text-xs font-bold text-[#FF9F1C] hover:bg-[#FF9F1C] hover:text-white transition-colors">Vào Trang Đồ Uống</a>
      </div>
    </div>

    <div class="glass-panel branch-card pointer-auto rounded-2xl" data-line-color="#8b5cf6" style="left: 70%; top: 20%;">
      <div class="drag-handle flex items-center gap-2 border-b border-gray-100/60 pb-2">
        <div class="w-2.5 h-2.5 rounded-full bg-[#8b5cf6] shadow-[0_0_8px_#8b5cf6]"></div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest flex-1">Di chuyển</p>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/></svg>
      </div>
      <div class="p-5 pt-3">
        <h3 class="font-black text-gray-800 text-lg leading-tight mb-2">Tài khoản & NS</h3>
        <p class="text-xs text-gray-500 mb-4">Quản lý <strong class="text-purple-500"><%= totalStaff %></strong> tài khoản nhân viên và Admin hệ thống.</p>
        <a href="<%= request.getContextPath() %>/admin/users" class="block text-center w-full py-2.5 bg-purple-50 rounded-xl text-xs font-bold text-purple-600 hover:bg-purple-500 hover:text-white transition-colors">Quản lý Nhân Sự</a>
      </div>
    </div>

    <div class="glass-panel branch-card pointer-auto rounded-2xl" data-line-color="#10b981" style="left: 10%; top: 65%;">
      <div class="drag-handle flex items-center gap-2 border-b border-gray-100/60 pb-2">
        <div class="w-2.5 h-2.5 rounded-full bg-[#10b981] shadow-[0_0_8px_#10b981]"></div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest flex-1">Di chuyển</p>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/></svg>
      </div>
      <div class="p-5 pt-3">
        <h3 class="font-black text-gray-800 text-lg leading-tight mb-2">Thống kê Báo cáo</h3>
        <p class="text-xs text-gray-500 mb-4">Phân tích biểu đồ và xem dòng tiền doanh thu cửa hàng.</p>
        <a href="<%= request.getContextPath() %>/admin/report" class="block text-center w-full py-2.5 bg-green-50 rounded-xl text-xs font-bold text-green-600 hover:bg-green-500 hover:text-white transition-colors">Xem Báo Cáo</a>
      </div>
    </div>

    <div class="glass-panel branch-card pointer-auto rounded-2xl" data-line-color="#3b82f6" style="left: 75%; top: 60%;">
      <div class="drag-handle flex items-center gap-2 border-b border-gray-100/60 pb-2">
        <div class="w-2.5 h-2.5 rounded-full bg-[#3b82f6] shadow-[0_0_8px_#3b82f6]"></div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest flex-1">Di chuyển</p>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/></svg>
      </div>
      <div class="p-5 pt-3">
        <h3 class="font-black text-gray-800 text-lg leading-tight mb-2">Tra cứu Hóa đơn</h3>
        <p class="text-xs text-gray-500 mb-4">Chi tiết <strong class="text-blue-500"><%= billToday %></strong> đơn hàng bán ra ngày hôm nay.</p>
        <a href="<%= request.getContextPath() %>/admin/bills" class="block text-center w-full py-2.5 bg-blue-50 rounded-xl text-xs font-bold text-blue-600 hover:bg-blue-500 hover:text-white transition-colors">Lịch sử Giao dịch</a>
      </div>
    </div>

    <% } else { %>

    <!-- GIAO DIỆN STAFF -->
    <div class="glass-panel branch-card pointer-auto rounded-2xl" data-line-color="#FF9F1C" style="left: 15%; top: 40%;">
      <div class="drag-handle flex items-center gap-2 border-b border-gray-100/60 pb-2">
        <div class="w-2.5 h-2.5 rounded-full bg-[#FF9F1C] shadow-[0_0_8px_#FF9F1C]"></div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest flex-1">Di chuyển</p>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/></svg>
      </div>
      <div class="p-5 pt-3">
        <h3 class="font-black text-gray-800 text-lg leading-tight mb-2">Tạo Hóa Đơn (POS)</h3>
        <p class="text-xs text-gray-500 mb-4">Giao diện lên đơn hàng tại quầy nhanh chóng cho khách.</p>
        <a href="<%= request.getContextPath() %>/staff/bills" class="block text-center w-full py-2.5 bg-[#FF9F1C] rounded-xl text-xs font-bold text-white shadow-md hover:bg-orange-600 transition-colors">Lên Đơn Ngay</a>
      </div>
    </div>

    <div class="glass-panel branch-card pointer-auto rounded-2xl" data-line-color="#10b981" style="left: 65%; top: 40%;">
      <div class="drag-handle flex items-center gap-2 border-b border-gray-100/60 pb-2">
        <div class="w-2.5 h-2.5 rounded-full bg-[#10b981] shadow-[0_0_8px_#10b981]"></div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest flex-1">Di chuyển</p>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="9" cy="12" r="1"/><circle cx="9" cy="5" r="1"/><circle cx="9" cy="19" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="5" r="1"/><circle cx="15" cy="19" r="1"/></svg>
      </div>
      <div class="p-5 pt-3">
        <h3 class="font-black text-gray-800 text-lg leading-tight mb-2">Thực đơn hiện tại</h3>
        <p class="text-xs text-gray-500 mb-4">Xem giá cả và thông tin của <strong class="text-green-500"><%= totalDrinks %></strong> món uống.</p>
        <a href="<%= request.getContextPath() %>/staff/drinks" class="block text-center w-full py-2.5 bg-green-50 rounded-xl text-xs font-bold text-green-600 hover:bg-green-500 hover:text-white transition-colors">Xem Menu</a>
      </div>
    </div>

    <% } %>
  </div>
</main>
<jsp:include page="/includes/app-footer.jsp"/>
</div>

<script>
// ==========================================
// 1. DRAG & DROP LOGIC & SVG LINES
// ==========================================
const svgLayer = document.getElementById('svg-layer');
const cards = Array.from(document.querySelectorAll('.branch-card'));
const mapData = []; // Lưu card và path để update mỗi frame

// Khởi tạo Path cho mỗi Card
cards.forEach((card, index) => {
  const color = card.getAttribute('data-line-color');

  // Tạo thẻ SVG path
  const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
  path.setAttribute('class', 'flow-line');
  path.setAttribute('stroke', color);
  path.setAttribute('fill', 'none');
  svgLayer.appendChild(path);

  mapData.push({ card: card, path: path });

  // --- LOGIC KÉO THẢ (DRAG & DROP) CHUẨN ---
  const handle = card.querySelector('.drag-handle');
  let isDragging = false;
  let offsetX = 0, offsetY = 0;

  handle.addEventListener('mousedown', (e) => {
    isDragging = true;

    // Đưa thẻ đang kéo lên trên cùng
    cards.forEach(c => c.style.zIndex = "10");
    card.style.zIndex = "100";

    // Tính toán độ lệch giữa vị trí click và góc trái/trên của thẻ
    const rect = card.getBoundingClientRect();
    const parentRect = document.getElementById('main-container').getBoundingClientRect();

    // Khoảng cách từ con trỏ chuột đến góc của thẻ
    offsetX = e.clientX - rect.left;
    offsetY = e.clientY - rect.top;

    // Thay vì đổi % thành px lúc kéo, ta ép nó thành px luôn cho mượt
    card.style.left = (rect.left - parentRect.left) + 'px';
    card.style.top = (rect.top - parentRect.top) + 'px';

    // Disable transition để khi kéo không bị lag do CSS can thiệp
    card.style.transition = "none";
  });

  // Gắn sự kiện vào document để chuột di chuyển nhanh vẫn bắt được
  document.addEventListener('mousemove', (e) => {
    if (!isDragging) return;

    const parentRect = document.getElementById('main-container').getBoundingClientRect();

    // Tính toạ độ mới (chỉ được giới hạn trong main-container nếu muốn, ở đây cho kéo tự do)
    let newLeft = e.clientX - parentRect.left - offsetX;
    let newTop = e.clientY - parentRect.top - offsetY;

    card.style.left = newLeft + 'px';
    card.style.top = newTop + 'px';

    updateSVGLines(); // Vẽ lại dây ngay khi kéo
  });

  document.addEventListener('mouseup', () => {
    if (isDragging) {
      isDragging = false;
      // Trả lại transition cho hiệu ứng hover shadow
      card.style.transition = "box-shadow 0.2s, border-color 0.2s";
    }
  });
});


// ==========================================
// 2. THREE.JS KHỞI TẠO (MÔ HÌNH CỐC CÀ PHÊ)
// ==========================================
const container = document.getElementById('canvas-container');
const scene = new THREE.Scene();

const camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 100);
camera.position.set(0, 8, 20);

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setSize(container.clientWidth, container.clientHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.0;
container.appendChild(renderer.domElement);

const controls = new THREE.OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.05;
controls.enablePan = false;
controls.minDistance = 10;
controls.maxDistance = 30;
// Giới hạn góc xoay để không nhìn xuống dưới đáy quá nhiều
controls.maxPolarAngle = Math.PI / 2 + 0.1;
controls.minPolarAngle = 0;

// Ánh sáng
const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
scene.add(ambientLight);
const dirLight = new THREE.DirectionalLight(0xffeedd, 1.5);
dirLight.position.set(5, 10, 7);
scene.add(dirLight);
const backLight = new THREE.PointLight(0xffffff, 0.5);
backLight.position.set(-5, 5, -5);
scene.add(backLight);

// Dựng model cái cốc
const mugGroup = new THREE.Group();
scene.add(mugGroup);

// Vật liệu gốm sứ
const ceramicMat = new THREE.MeshPhysicalMaterial({
  color: 0xffffff, roughness: 0.2, metalness: 0.1, clearcoat: 0.8, clearcoatRoughness: 0.1, side: THREE.DoubleSide
});

// Thân, đáy, miệng, quai
const body = new THREE.Mesh(new THREE.CylinderGeometry(1.6, 1.3, 3.2, 64, 1, true), ceramicMat);
const bottom = new THREE.Mesh(new THREE.CircleGeometry(1.3, 64), ceramicMat);
bottom.rotation.x = Math.PI / 2; bottom.position.y = -1.6;
const rim = new THREE.Mesh(new THREE.TorusGeometry(1.6, 0.08, 64, 64), ceramicMat);
rim.rotation.x = Math.PI / 2; rim.position.y = 1.6;
const handle = new THREE.Mesh(new THREE.TorusGeometry(0.9, 0.25, 32, 64), ceramicMat);
handle.position.set(1.5, 0, 0); handle.scale.set(0.8, 1.3, 1);

mugGroup.add(body, bottom, rim, handle);

// Nước cà phê
const liquidGeo = new THREE.CircleGeometry(1.5, 64);
const liquidMat = new THREE.MeshPhysicalMaterial({ color: 0x2b1408, roughness: 0.1, metalness: 0.1 });
const liquid = new THREE.Mesh(liquidGeo, liquidMat);
liquid.rotation.x = -Math.PI / 2; liquid.position.y = 1.3;
mugGroup.add(liquid);

// Hiệu ứng hạt cà phê bay lơ lửng xung quanh (trang trí)
const particles = new THREE.Group();
scene.add(particles);
const pMat = new THREE.MeshBasicMaterial({ color: 0xFF9F1C, transparent: true, opacity: 0.6 });
const pGeo = new THREE.SphereGeometry(0.05, 8, 8);
for(let i=0; i<15; i++) {
  const p = new THREE.Mesh(pGeo, pMat);
  p.position.set((Math.random()-0.5)*10, Math.random()*8, (Math.random()-0.5)*10);
  p.userData = { speedY: 0.01 + Math.random()*0.02, speedRot: Math.random()*0.05 };
  particles.add(p);
}


// ==========================================
// 3. HÀM CẬP NHẬT SVG LINES (CHẠY MỖI FRAME)
// ==========================================
// Điểm neo trên 3D: Lấy ngay tâm của cốc cà phê (cao lên 1 chút)
const anchor3D = new THREE.Vector3(0, 1.5, 0);

function updateSVGLines() {
  const rect = container.getBoundingClientRect();
  const vector = anchor3D.clone();

  // Chuyển đổi toạ độ 3D sang 2D (Màn hình)
  vector.project(camera);
  const startX = (vector.x * .5 + .5) * rect.width;
  const startY = (-(vector.y * .5) + .5) * rect.height;

  mapData.forEach(item => {
    const cardRect = item.card.getBoundingClientRect();
    const parentRect = document.getElementById('main-container').getBoundingClientRect();

    // Tính tâm của thẻ (so với container chứa SVG)
    const cardCenterX = cardRect.left - parentRect.left + cardRect.width / 2;
    const cardCenterY = cardRect.top - parentRect.top + cardRect.height / 2;

    // Tìm điểm kết nối ở rìa thẻ thay vì cắm thẳng vào tâm thẻ
    let endX, endY;
    if (startX < cardRect.left - parentRect.left) {
        endX = cardRect.left - parentRect.left; // Rìa trái
    } else if (startX > cardRect.right - parentRect.left) {
        endX = cardRect.right - parentRect.left; // Rìa phải
    } else {
        endX = cardCenterX; // Nối ở giữa nếu nằm trên/dưới
    }
    endY = cardCenterY;

    // Vẽ đường cong Bezier (Cubic) mượt mà
    // M startX startY C controlX1 controlY1, controlX2 controlY2, endX endY
    const curveTightness = 0.5; // Độ uốn cong
    const control1X = startX + (endX - startX) * curveTightness;
    const control1Y = startY;
    const control2X = endX - (endX - startX) * curveTightness;
    const control2Y = endY;

    const pathString = `M ${startX} ${startY} C ${control1X} ${control1Y}, ${control2X} ${control2Y}, ${endX} ${endY}`;
    item.path.setAttribute('d', pathString);
  });
}

// ==========================================
// 4. VÒNG LẶP ANIMATION CHÍNH
// ==========================================
function animate() {
  requestAnimationFrame(animate);

  // Quay cốc nhẹ nhẹ nếu không thao tác
  controls.update();

  // Hạt lơ lửng
  particles.children.forEach(p => {
    p.position.y += p.userData.speedY;
    if(p.position.y > 8) p.position.y = -2;
    p.rotation.x += p.userData.speedRot;
    p.rotation.y += p.userData.speedRot;
  });

  // Liên tục cập nhật dây nối (Quan trọng: Để khi xoay 3D dây vẫn bám đúng)
  updateSVGLines();

  renderer.render(scene, camera);
}

// Resize Responsive
window.addEventListener('resize', () => {
  camera.aspect = container.clientWidth / container.clientHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(container.clientWidth, container.clientHeight);
});

// Khởi chạy
window.onload = () => {
  animate();

  // Hiệu ứng GSAP mượt mà lúc load
  gsap.from('.stat-badge', { y: -30, opacity: 0, stagger: 0.1, duration: 0.8, ease: "power3.out" });

  // Hiệu ứng cho các Card
  cards.forEach(card => {
    gsap.from(card, {
      opacity: 0, scale: 0.8, y: 50,
      duration: 0.8, ease: "back.out(1.2)",
      delay: Math.random() * 0.4
    });
  });

  // Hiệu ứng vẽ dây
  gsap.from('.flow-line', {
    strokeDashoffset: 100, strokeDasharray: 100,
    duration: 1.5, ease: "power2.inOut",
    delay: 0.5
  });
};
</script>
<jsp:include page="/includes/sidebar-gsap.jsp"/>
</body>
</html>