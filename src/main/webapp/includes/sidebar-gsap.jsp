<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script>
(function initDashboardSidebar() {
  const sidebar = document.getElementById('dashboard-sidebar');
  const btn = document.getElementById('sidebarLogoBtn');
  const brand = document.getElementById('sidebarBrand');
  const nav = document.getElementById('sidebarNav');
  const userBox = document.getElementById('sidebarUser');
  if (!sidebar || !btn || !brand || !nav || !userBox || typeof gsap === 'undefined') return;

  let open = true;
  let busy = false;

function expand() {
    if (open || busy) return;
    busy = true;
    open = true;
    sidebar.setAttribute('data-open', 'true');
    btn.setAttribute('aria-expanded', 'true');
    nav.setAttribute('aria-hidden', 'false');
    userBox.setAttribute('aria-hidden', 'false');

    nav.style.visibility = 'visible';
    nav.style.pointerEvents = 'auto';
    userBox.style.visibility = 'visible';
    userBox.style.pointerEvents = 'auto';

    // ✅ Reset tất cả về trạng thái ban đầu rõ ràng
    gsap.set(nav, { opacity: 0 });
    gsap.set(userBox, { opacity: 0, y: 16 });
    gsap.set(nav.children, { opacity: 0, y: -14 }); // ✅ set rõ điểm xuất phát

    const tl = gsap.timeline({ onComplete: function () { busy = false; } });
    tl.to(sidebar, { width: '15rem', duration: 0.52, ease: 'power2.inOut' })
      .to(brand, { maxWidth: 220, opacity: 1, duration: 0.42, ease: 'power2.out' }, '-=0.28')
      .to(nav, { opacity: 1, duration: 0.12 })
      .to(nav.children, {           // ✅ .to() thay vì .from()
        opacity: 1,
        y: 0,
        stagger: 0.05,
        duration: 0.42,
        ease: 'power2.out'
      }, '<0.05')
      .to(userBox,
        { opacity: 1, y: 0, duration: 0.38, ease: 'power2.out' }
      );
  }

  function collapse() {
    if (!open || busy) return;
    busy = true;
    open = false;
    sidebar.setAttribute('data-open', 'false');
    btn.setAttribute('aria-expanded', 'false');
    nav.setAttribute('aria-hidden', 'true');
    userBox.setAttribute('aria-hidden', 'true');

    const kids = Array.from(nav.children);
    const tl = gsap.timeline({
      onComplete: function () {
        nav.style.visibility = 'hidden';
        nav.style.pointerEvents = 'none';
        gsap.set(nav, { opacity: 0 });
        userBox.style.visibility = 'hidden';
        userBox.style.pointerEvents = 'none';
        gsap.set(userBox, { opacity: 0, y: 0 });
        busy = false;
      }
    });
    tl.to(userBox, { opacity: 0, y: 10, duration: 0.24, ease: 'power2.in' })
      .to(kids, { opacity: 0, y: -10, stagger: -0.04, duration: 0.22, ease: 'power2.in' }, 0.06)
      .to(brand, { maxWidth: 0, opacity: 0, duration: 0.32, ease: 'power2.inOut' }, '-=0.08')
      .to(sidebar, { width: '4rem', duration: 0.48, ease: 'power2.inOut' }, '-=0.14');
  }

  btn.addEventListener('click', function () { open ? collapse() : expand(); });
})();
</script>
