<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User, entity.Drink, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    List<Drink> drinks = (List<Drink>) request.getAttribute("drinks");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    String keyword = (String) request.getAttribute("keyword");

    if(currentPage == null) currentPage = 1;
    if(totalPages == null) totalPages = 1;
    if(keyword == null) keyword = "";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/includes/head-common.jsp">
  <jsp:param name="title" value="Xem đồ uống | Polly Coffee"/>
</jsp:include>
<style>
  .drink-card { opacity:1; }
</style>
</head>

<body class="flex min-h-screen">

<% request.setAttribute("activeNav", "staff_drinks");
   request.setAttribute("pageHeading", "Thực đơn");
   request.setAttribute("pageSubheading", "Danh sách đồ uống hiện có"); %>

<jsp:include page="/includes/dashboard-sidebar.jsp"/>

<div class="flex min-h-screen min-w-0 flex-1 flex-col">

<jsp:include page="/includes/app-header.jsp"/>

<main class="flex-1 overflow-auto p-8">

  <div id="page-header" class="mb-6 flex items-center justify-end">
    <input type="text" id="searchInput" placeholder="🔍 Tìm kiếm tên..."
           class="border-2 border-gray-200 rounded-xl px-4 py-2 text-sm font-bold outline-none focus:border-orange-400 transition-colors"
           oninput="filterDrinks()">
  </div>

  <!-- Category filter -->
  <div class="flex gap-2 mb-6 flex-wrap" id="catFilter">

    <button onclick="filterCat('',this)"
      class="cat-btn active px-4 py-2 rounded-xl text-xs font-black border-2 border-orange-400 text-orange-500 bg-orange-50 transition">
      Tất cả
    </button>

    <%
      java.util.Set<String> cats = new java.util.LinkedHashSet<>();
      if (drinks != null)
          for (Drink d : drinks)
              if (d.getCategory() != null)
                  cats.add(d.getCategory());

      for (String cat : cats) {
    %>

    <button onclick="filterCat('<%= cat %>',this)"
      class="cat-btn px-4 py-2 rounded-xl text-xs font-black border-2 border-gray-200 text-gray-500 hover:border-orange-300 hover:text-orange-400 transition bg-white">
      <%= cat %>
    </button>

    <% } %>

  </div>


  <!-- Drink grid -->

  <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" id="drinkGrid">

    <% if (drinks != null) for (Drink d : drinks) {

        String imgUrl = (d.getImage() != null && !d.getImage().isEmpty())
                ? request.getContextPath() + "/" + d.getImage()
                : request.getContextPath() + "/img/default-drink.png";

    %>

    <div class="drink-card bg-white rounded-2xl p-5 shadow-sm border border-orange-50 hover:border-orange-300 hover:shadow-md transition-all cursor-pointer"
         data-name="<%= d.getDrinkName().toLowerCase() %>"
         data-cat="<%= d.getCategory() %>">

      <div class="w-full h-32 mb-4 rounded-xl overflow-hidden bg-gray-50">
          <img src="<%= imgUrl %>" class="w-full h-full object-cover" alt="<%= d.getDrinkName() %>">
      </div>

      <h3 class="font-black text-gray-900 text-base mb-1 truncate">
          <%= d.getDrinkName() %>
      </h3>

      <span class="text-xs font-bold text-gray-500 bg-gray-100 px-2 py-1 rounded-lg">
          <%= d.getCategory() %>
      </span>

      <div class="flex items-center justify-between mt-4">

        <p class="text-lg font-black text-[#FF9F1C]">
            <%= String.format("%,.0f", d.getPrice()) %>đ
        </p>

        <span class="inline-block text-[10px] font-black px-2 py-1 rounded-full
            <%= d.isStatus() ? "bg-green-100 text-green-600" : "bg-red-100 text-red-500" %>">

            <%= d.isStatus() ? "Sẵn sàng" : "Hết món" %>

        </span>

      </div>

    </div>

    <% } %>

  </div>



  <!-- Pagination -->

  <div class="flex justify-center mt-8 gap-2">

  <% if(currentPage > 1){ %>

    <a href="<%= request.getContextPath() %>/staff/drinks?page=<%= currentPage-1 %>&keyword=<%= keyword %>"
       class="px-4 py-2 border rounded-lg font-bold hover:bg-gray-100">
       «
    </a>

  <% } %>



  <% for(int i = 1; i <= totalPages; i++){ %>

      <a href="<%= request.getContextPath() %>/staff/drinks?page=<%= i %>&keyword=<%= keyword %>"
         class="px-4 py-2 border rounded-lg font-bold
         <%= (i == currentPage) ? "bg-orange-500 text-white border-orange-500" : "hover:bg-gray-100" %>">

         <%= i %>

      </a>

  <% } %>



  <% if(currentPage < totalPages){ %>

    <a href="<%= request.getContextPath() %>/staff/drinks?page=<%= currentPage+1 %>&keyword=<%= keyword %>"
       class="px-4 py-2 border rounded-lg font-bold hover:bg-gray-100">
       »
    </a>

  <% } %>

  </div>


</main>



<script>
  let currentCat = '';

  function filterCat(cat, btnElement) {
    currentCat = cat;

    document.querySelectorAll('.cat-btn').forEach(btn => {
      btn.classList.remove('border-orange-400', 'text-orange-500', 'bg-orange-50');
      btn.classList.add('border-gray-200', 'text-gray-500', 'bg-white');
    });

    btnElement.classList.remove('border-gray-200', 'text-gray-500', 'bg-white');
    btnElement.classList.add('border-orange-400', 'text-orange-500', 'bg-orange-50');

    filterDrinks();
  }

  function filterDrinks() {

    const query = document.getElementById('searchInput').value.toLowerCase().trim();
    const cards = document.querySelectorAll('.drink-card');

    let showingCards = [];

    cards.forEach(card => {

      const name = card.getAttribute('data-name');
      const cat = card.getAttribute('data-cat');

      const matchSearch = name.includes(query);
      const matchCat = (currentCat === '' || cat === currentCat);

      if (matchSearch && matchCat) {
        card.style.display = 'block';
        showingCards.push(card);
      } else {
        card.style.display = 'none';
      }

    });

    if(showingCards.length > 0){
        gsap.fromTo(showingCards,
            { y:20, opacity:0 },
            { y:0, opacity:1, duration:0.3, stagger:0.05, ease:'power2.out', clearProps:"all"}
        );
    }

  }

  window.addEventListener('DOMContentLoaded', () => {

    const tl = gsap.timeline();

    tl.from('#page-header', { y:-20, opacity:0, duration:0.5, ease:'power2.out' });
    tl.from('#catFilter', { opacity:0, duration:0.4 }, "-=0.2");
    tl.from('.drink-card', { y:20, opacity:0, stagger:0.05, duration:0.4, ease:'back.out(1.5)', clearProps:"all"}, "-=0.2");

  });

</script>


<jsp:include page="/includes/app-footer.jsp"/>

</div>

<jsp:include page="/includes/sidebar-gsap.jsp"/>

</body>
</html>