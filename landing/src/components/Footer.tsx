import { Link } from "react-router-dom";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="wrap">
        <div className="footer-inner">
          <Link to="/" className="brand" aria-label="90DAYRUN home">
            <img src="/logo.png" alt="90DAYRUN" className="brand-logo" />
          </Link>
          <div className="links">
            <Link to="/support">Support</Link>
            <Link to="/privacy">Privacy</Link>
            <Link to="/terms">Terms</Link>
            <a href="mailto:hxndrd@gmail.com">Contact</a>
          </div>
        </div>
        <div className="legal">
          © 2026 HXNDRD HOLDING LLC. ALL RIGHTS RESERVED.<br />
          90DAYRUN IS A PRODUCT OF HXNDRD HOLDING LLC · 32 N GOULD ST., SHERIDAN, WY 82801
        </div>
      </div>
    </footer>
  );
}
