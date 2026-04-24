<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User, entity.Drink, java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isRole()) { response.sendRedirect(request.getContextPath() + "/index"); return; }
    List<Drink> drinks = (List<Drink>) request.getAttribute("drinks");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/includes/head-common.jsp">
  <jsp:param name="title" value="Quản lý đồ uống | Polly Coffee"/>
</jsp:include>
<style>
  .modal { display:none;position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:50;align-items:center;justify-content:center; }
  .modal.open { display:flex; }
  .field { width:100%;padding:10px 14px;background:#F9FAFB;border:2px solid transparent;border-radius:12px;outline:none;font-size:.85rem;font-weight:700;font-family:'Plus Jakarta Sans',sans-serif;transition:border-color .2s; }
  .field:focus { border-color:#FF9F1C;background:#fff; }

  /* CSS HIỆU ỨNG UPLOAD FOLDER */
  .upload-container {
    --transition: 350ms;
    --folder-W: 100px;
    --folder-H: 65px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-end;
    padding: 10px;
    background: linear-gradient(135deg, #ff9800, #e65100);
    border-radius: 15px;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
    height: calc(var(--folder-H) * 1.7);
    position: relative;
    width: 100%;
    margin-top: 10px;
  }
  .folder {
    position: absolute;
    top: -15px;
    left: calc(50% - 50px);
    animation: float 2.5s infinite ease-in-out;
    transition: transform var(--transition) ease;
  }
  .folder:hover { transform: scale(1.05); }
  .folder .front-side, .folder .back-side {
    position: absolute;
    transition: transform var(--transition);
    transform-origin: bottom center;
  }
  .folder .back-side::before, .folder .back-side::after {
    content: ""; display: block; background-color: white; opacity: 0.5;
    z-index: 0; width: var(--folder-W); height: var(--folder-H);
    position: absolute; transform-origin: bottom center;
    border-radius: 12px; transition: transform 350ms;
  }
  .upload-container:hover .back-side::before { transform: rotateX(-5deg) skewX(5deg); }
  .upload-container:hover .back-side::after { transform: rotateX(-15deg) skewX(12deg); }
  .folder .front-side { z-index: 1; }
  .upload-container:hover .front-side { transform: rotateX(-40deg) skewX(15deg); }
  .folder .tip {
    background: linear-gradient(135deg, #ff9a56, #ff6f56);
    width: 60px; height: 15px; border-radius: 10px 10px 0 0;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
    position: absolute; top: -10px; z-index: 2;
  }
  .folder .cover {
    background: linear-gradient(135deg, #ffe563, #ffc663);
    width: var(--folder-W); height: var(--folder-H);
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3); border-radius: 8px;
  }
  .custom-file-upload {
    font-size: 0.85em; font-weight: 700; color: #ffffff; text-align: center;
    background: rgba(255, 255, 255, 0.2); border: none; border-radius: 10px;
    box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1); cursor: pointer;
    transition: background var(--transition) ease;
    display: inline-block; width: 100%; padding: 8px 15px; position: relative; z-index: 10;
  }
  .custom-file-upload:hover { background: rgba(255, 255, 255, 0.4); }
  .custom-file-upload input[type="file"] { display: none; }
  @keyframes float {
    0% { transform: translateY(0px); }
    50% { transform: translateY(-15px); }
    100% { transform: translateY(0px); }
  }
  /* Preivew Image box */
  .img-preview { width: 60px; height: 60px; border-radius: 12px; object-fit: cover; display: none; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); }
</style>
</head>
<body class="flex min-h-screen">
<% request.setAttribute("activeNav", "admin_drinks");
   request.setAttribute("pageHeading", "Quản lý đồ uống");
   request.setAttribute("pageSubheading", "Thêm, sửa, xoá thực đơn"); %>
<jsp:include page="/includes/dashboard-sidebar.jsp"/>
<div class="flex min-h-screen min-w-0 flex-1 flex-col">
<jsp:include page="/includes/app-header.jsp"/>
<main class="flex-1 overflow-auto p-8">
<div id="page-header" class="mb-6 flex items-center justify-between">

  <!-- SEARCH -->
  <form method="get" action="${pageContext.request.contextPath}/admin/drinks"
        class="flex gap-2">

      <input type="text"
             name="keyword"
             value="${keyword}"
             placeholder="Tìm đồ uống..."
             class="border-2 border-gray-200 rounded-xl px-4 py-2 text-sm font-bold outline-none focus:border-orange-400">

      <button type="submit"
              class="bg-gray-800 text-white px-4 py-2 rounded-xl text-sm font-bold">
          Tìm
      </button>

  </form>

  <!-- ADD BUTTON -->
  <button onclick="openAdd()"
          class="bg-[#FF9F1C] text-white font-black px-5 py-2.5 rounded-xl hover:opacity-90 transition flex items-center gap-2">
      + Thêm mới
  </button>

</div>

  <div class="bg-white rounded-2xl shadow-sm border border-orange-50 overflow-hidden">
    <table class="w-full">
      <thead class="bg-gray-50">
        <tr>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Ảnh</th>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Tên</th>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Danh mục</th>
          <th class="text-right px-5 py-3 text-xs font-black text-gray-400 uppercase">Giá</th>
          <th class="text-center px-5 py-3 text-xs font-black text-gray-400 uppercase">Trạng thái</th>
          <th class="text-center px-5 py-3 text-xs font-black text-gray-400 uppercase">Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <% if (drinks != null) for (Drink d : drinks) {
            String imgUrl = (d.getImage() != null && !d.getImage().isEmpty()) ? request.getContextPath() + "/" + d.getImage() : request.getContextPath() + "/img/default-drink.png";
        %>
        <tr class="border-b border-gray-50 hover:bg-orange-50 transition">
          <td class="px-5 py-3"><img src="<%= imgUrl %>" class="w-10 h-10 object-cover rounded-lg border border-gray-100" alt="<%= d.getDrinkName() %>"></td>
          <td class="px-5 py-4 font-black text-sm text-gray-800"><%= d.getDrinkName() %></td>
          <td class="px-5 py-4"><span class="text-xs font-bold text-gray-500 bg-gray-100 px-2 py-1 rounded-lg"><%= d.getCategory() %></span></td>
          <td class="px-5 py-4 text-right font-black text-[#FF9F1C]"><%= String.format("%,.0f", d.getPrice()) %>đ</td>
          <td class="px-5 py-4 text-center">
            <span class="text-xs font-black px-2 py-1 rounded-full <%= d.isStatus() ? "bg-green-100 text-green-600" : "bg-red-100 text-red-400" %>">
              <%= d.isStatus() ? "Còn hàng" : "Hết hàng" %>
            </span>
          </td>
          <td class="px-5 py-4 text-center">
            <div class="flex items-center justify-center gap-2">
              <button onclick="openEdit(<%= d.getDrinkId() %>,'<%= d.getDrinkName().replace("'","\\'") %>',<%= d.getPrice() %>,'<%= d.getCategory() %>',<%= d.isStatus() %>,'<%= imgUrl %>')"
                      class="text-xs font-black px-3 py-1.5 rounded-lg border-2 border-orange-300 text-orange-500 hover:bg-orange-50 transition">Sửa</button>
            </div>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <!-- PAGINATION -->
  <div class="flex justify-center gap-2 mt-6">

  <c:if test="${currentPage > 1}">
    <a href="?page=${currentPage-1}&keyword=${keyword}"
       class="px-3 py-1 border rounded-lg bg-white hover:bg-orange-50">
       Previous
    </a>
  </c:if>

  <c:forEach begin="1" end="${totalPages}" var="i">

    <a href="?page=${i}&keyword=${keyword}"
       class="px-3 py-1 border rounded-lg ${i==currentPage?'bg-orange-400 text-white':'bg-white hover:bg-orange-50'}">
       ${i}
    </a>

  </c:forEach>

  <c:if test="${currentPage < totalPages}">
    <a href="?page=${currentPage+1}&keyword=${keyword}"
       class="px-3 py-1 border rounded-lg bg-white hover:bg-orange-50">
       Next
    </a>
  </c:if>

  </div>
</main>

<!-- ADD MODAL -->
<div class="modal" id="addModal">
  <div class="bg-white rounded-2xl p-6 w-full max-w-md shadow-2xl">
    <h3 class="font-black text-lg mb-4">Thêm đồ uống mới</h3>
    <!-- Quan trọng: enctype="multipart/form-data" -->
    <form action="<%= request.getContextPath() %>/admin/drinks" method="post" enctype="multipart/form-data">
      <input type="hidden" name="action" value="add">
      <div class="space-y-3">
        <div><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Tên đồ uống</label>
          <input type="text" name="drinkName" required class="field" placeholder="VD: Cà phê đen"></div>
        <div class="flex gap-3">
            <div class="flex-1"><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Giá (đ)</label>
              <input type="number" name="price" required class="field" placeholder="25000"></div>
            <div class="flex-1"><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Danh mục</label>
              <input type="text" name="category" required class="field" placeholder="VD: Cà phê"></div>
        </div>

        <!-- UPLOAD FOLDER COMPONENT -->
        <div>
          <label class="text-xs font-black text-gray-400 uppercase mb-1 flex justify-between items-center">
            <span>Hình ảnh</span>
            <img id="previewImgAdd" class="img-preview" src="" alt="Preview">
          </label>
          <div class="upload-container">
            <div class="folder">
              <div class="front-side">
                <div class="tip"></div>
                <div class="cover"></div>
              </div>
              <div class="back-side cover"></div>
            </div>
            <label class="custom-file-upload">
              <!-- Name="image" phải trùng với servlet -->
              <input class="title" type="file" name="image" accept="image/*" onchange="previewImage(this, 'previewImgAdd', 'lblAdd')" />
              <span id="lblAdd">Tải ảnh lên</span>
            </label>
          </div>
        </div>
      </div>
      <div class="flex gap-3 mt-5">
        <button type="submit" class="flex-1 bg-[#FF9F1C] text-white font-black py-3 rounded-xl hover:opacity-90">Thêm</button>
        <button type="button" onclick="closeModal('addModal')" class="flex-1 border-2 border-gray-200 font-black py-3 rounded-xl text-gray-500 hover:border-gray-300">Hủy</button>
      </div>
    </form>
  </div>
</div>

<!-- EDIT MODAL -->
<div class="modal" id="editModal">
  <div class="bg-white rounded-2xl p-6 w-full max-w-md shadow-2xl">
    <h3 class="font-black text-lg mb-4">Sửa đồ uống</h3>
    <!-- Quan trọng: enctype="multipart/form-data" -->
    <form action="<%= request.getContextPath() %>/admin/drinks" method="post" enctype="multipart/form-data">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="drinkId" id="editId">
      <div class="space-y-3">
        <div><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Tên đồ uống</label>
          <input type="text" name="drinkName" id="editName" required class="field"></div>
        <div class="flex gap-3">
            <div class="flex-1"><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Giá (đ)</label>
              <input type="number" name="price" id="editPrice" required class="field"></div>
            <div class="flex-1"><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Danh mục</label>
              <input type="text" name="category" id="editCategory" required class="field"></div>
        </div>
        <div><label class="text-xs font-black text-gray-400 uppercase mb-1 block">Trạng thái</label>
          <select name="status" id="editStatus" class="field" style="appearance:none">
            <option value="true">Còn hàng</option>
            <option value="false">Hết hàng</option>
          </select>
        </div>

        <!-- UPLOAD FOLDER COMPONENT -->
        <div>
            <label class="text-xs font-black text-gray-400 uppercase mb-1 flex justify-between items-center">
              <span>Cập nhật hình ảnh</span>
              <img id="previewImgEdit" class="img-preview" src="" alt="Preview">
            </label>
            <div class="upload-container">
              <div class="folder">
                <div class="front-side">
                  <div class="tip"></div>
                  <div class="cover"></div>
                </div>
                <div class="back-side cover"></div>
              </div>
              <label class="custom-file-upload">
                <input class="title" type="file" name="image" accept="image/*" onchange="previewImage(this, 'previewImgEdit', 'lblEdit')" />
                <span id="lblEdit">Đổi ảnh mới</span>
              </label>
            </div>
        </div>

      </div>
      <div class="flex gap-3 mt-5">
        <button type="submit" class="flex-1 bg-[#FF9F1C] text-white font-black py-3 rounded-xl hover:opacity-90">Lưu</button>
        <button type="button" onclick="closeModal('editModal')" class="flex-1 border-2 border-gray-200 font-black py-3 rounded-xl text-gray-500">Hủy</button>
      </div>
    </form>
  </div>
</div>

<script>
function openAdd() {
  document.getElementById('addModal').classList.add('open');
  document.getElementById('previewImgAdd').style.display = 'none';
  document.getElementById('lblAdd').innerText = 'Tải ảnh lên';
}

function openEdit(id, name, price, cat, status, imgUrl) {
  document.getElementById('editId').value = id;
  document.getElementById('editName').value = name;
  document.getElementById('editPrice').value = price;
  document.getElementById('editCategory').value = cat;
  document.getElementById('editStatus').value = status;

  // Hiện ảnh đang có
  let imgPreview = document.getElementById('previewImgEdit');
  imgPreview.src = imgUrl;
  imgPreview.style.display = 'block';
  document.getElementById('lblEdit').innerText = 'Đổi ảnh mới';

  document.getElementById('editModal').classList.add('open');
}

function closeModal(id) { document.getElementById(id).classList.remove('open'); }

// Script hiển thị trước hình ảnh khi upload
function previewImage(input, imgId, labelId) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            let img = document.getElementById(imgId);
            img.src = e.target.result;
            img.style.display = 'block';
        }
        reader.readAsDataURL(input.files[0]);
        // Rút gọn tên file nếu quá dài
        let fileName = input.files[0].name;
        if(fileName.length > 15) fileName = fileName.substring(0,12) + "...";
        document.getElementById(labelId).innerText = fileName;
    }
}

window.addEventListener('click', e => {
  if (e.target.classList.contains('modal')) e.target.classList.remove('open');
});

window.addEventListener('DOMContentLoaded', () => {
  const tl = gsap.timeline();
  tl.from('#page-header', { y: 20, opacity: 0, duration: 0.6, ease: 'power3.out' });
  tl.from('tbody tr', { y: 15, opacity: 0, stagger: 0.04, duration: 0.4, ease: 'power2.out', clearProps: "all" }, "-=0.2");
});
</script>
<jsp:include page="/includes/app-footer.jsp"/>
</div>
<jsp:include page="/includes/sidebar-gsap.jsp"/>
</body>
</html>