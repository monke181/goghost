import { Link, NavLink } from "react-router-dom";
import { motion } from "framer-motion";

export default function Nav() {
  return (
    <nav className="nav">
      <div className="nav-inner">
        <Link to="/" className="brand" aria-label="90DAYRUN home">
          <motion.img
            src="/logo.png"
            alt="90DAYRUN"
            className="brand-logo"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
          />
        </Link>
        <div className="nav-links">
          <a href="/#features" className="hideable">Features</a>
          <a href="/#levels" className="hideable">Levels</a>
          <a href="/#pricing" className="hideable">Pricing</a>
          <NavLink to="/support">Support</NavLink>
        </div>
      </div>
    </nav>
  );
}
