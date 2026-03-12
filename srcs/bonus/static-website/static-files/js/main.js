/*  Superlist-style scroll animations + staggered reveals  */

document.addEventListener('DOMContentLoaded', () => {

	/* ── Staggered fade-up on scroll ───────────────── */
    const faders = document.querySelectorAll('.fade-up');

    const observer = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    observer.unobserve(entry.target);
                }
            });
        },
        { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
    );

    faders.forEach((el) => observer.observe(el));

    /* ── Navbar blur-on-scroll ─────────────────────── */
    const navbar = document.querySelector('.navbar');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const y = window.scrollY;
        if (y > 60) {
            navbar.style.borderBottomColor = 'rgba(255,255,255,0.08)';
        } else {
            navbar.style.borderBottomColor = 'rgba(255,255,255,0.03)';
        }
        lastScroll = y;
    }, { passive: true });

    /* ── Smooth scroll for anchor links ────────────── */
    document.querySelectorAll('a[href^="#"]').forEach((link) => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const target = document.querySelector(link.getAttribute('href'));
            if (target) {
                const offset = 80; // account for fixed nav
                const top = target.getBoundingClientRect().top + window.scrollY - offset;
                window.scrollTo({ top, behavior: 'smooth' });
            }
        });
    });

    /* ── Subtle parallax on hero glow ──────────────── */
    const glow = document.querySelector('.hero-glow');
    if (glow) {
        window.addEventListener('mousemove', (e) => {
            const x = (e.clientX / window.innerWidth - 0.5) * 30;
            const y = (e.clientY / window.innerHeight - 0.5) * 30;
            glow.style.transform = `translate(calc(-50% + ${x}px), ${y}px)`;
        }, { passive: true });
    }
});