import { motion } from "framer-motion";
import Reveal from "../components/Reveal";
import CountUp from "../components/CountUp";

const features = [
  {
    h: "The Run",
    p: "One 90-day window. Set your focus areas, list your goals, and write down why you're doing it. A fixed start and a fixed finish.",
  },
  {
    h: "Ghost Mode",
    p: "Pick the apps that pull your attention and start a session. They stay blocked on-device through Apple Screen Time until you're done.",
  },
  {
    h: "Daily Check-Ins",
    p: "A short check-in in the morning, another at night. Each one is logged and rolls up into your discipline score.",
  },
  {
    h: "Discipline Score",
    p: "Every day gets scored. A 7-day momentum read shows whether you're trending up, holding steady, or falling off.",
  },
  {
    h: "Streak & Freeze",
    p: "Keep the streak going day to day. A streak freeze covers one missed day so a single off-day doesn't reset everything.",
  },
  {
    h: "Weekly Recap",
    p: "A clean summary of the week — your scores, streak, and check-ins in one place so you can see how it actually went.",
  },
];

const levels = [
  { rank: "01", name: "Civilian", tag: "Just getting started.", w: "20%" },
  { rank: "02", name: "Grinder", tag: "Putting in the work.", w: "40%" },
  { rank: "03", name: "Ghost", tag: "Locked in. Fading into the work.", w: "60%" },
  { rank: "04", name: "Phantom", tag: "They don't even see you coming.", w: "80%" },
  { rank: "05", name: "Elite", tag: "A different breed entirely.", w: "100%", peak: true },
];

// stagger container for the hero headline
const headline = {
  hidden: {},
  show: { transition: { staggerChildren: 0.12, delayChildren: 0.1 } },
};
const line = {
  hidden: { opacity: 0, y: 22 },
  show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] } },
};

export default function Home() {
  return (
    <>
      {/* ── HERO ─────────────────────────────── */}
      <header className="hero">
        <div className="wrap">
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
            className="hero-top"
          >
            <span className="label">90-DAY RUN</span>
            <span className="label" style={{ color: "var(--text-3)" }}>iOS</span>
          </motion.div>

          <motion.h1 variants={headline} initial="hidden" animate="show">
            <motion.span variants={line} style={{ display: "block" }}>90 days.</motion.span>
            <motion.span variants={line} style={{ display: "block" }}>
              No <span className="accent">noise</span>.<span className="cursor" />
            </motion.span>
          </motion.h1>

          <motion.p
            className="hero-sub"
            initial={{ opacity: 0, y: 14 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4 }}
          >
            A discipline tracker for one 90-day run. Set your focus, block the distractions,
            and check in every day. Your score is just the work you actually did.
          </motion.p>

          <motion.div
            className="cta-row"
            initial={{ opacity: 0, y: 14 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.5 }}
          >
            <a className="btn" href="#download">Get the app</a>
            <a className="btn btn-ghost" href="#features">How it works</a>
          </motion.div>

          {/* dashboard strip — mirrors the in-app header */}
          <motion.div
            className="counter-strip"
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.6 }}
          >
            <div className="counter-cell">
              <span className="label">Day</span>
              <div className="num accent"><CountUp to={37} /> <span style={{ fontSize: 22, color: "var(--text-3)" }}>/ 90</span></div>
            </div>
            <div className="counter-cell">
              <span className="label">Discipline</span>
              <div className="num"><CountUp to={82} /></div>
            </div>
            <div className="counter-cell">
              <span className="label">Streak</span>
              <div className="num"><CountUp to={14} /></div>
            </div>
            <div className="counter-cell">
              <span className="label">Level</span>
              <div className="num" style={{ fontSize: 40, paddingTop: 8 }}>PHANTOM</div>
            </div>
          </motion.div>
        </div>
      </header>

      {/* ── FEATURES ─────────────────────────── */}
      <section id="features">
        <div className="wrap">
          <Reveal className="sec-head">
            <span className="label">Features</span>
            <h2>The few things that actually matter.</h2>
            <p>No feeds, no clutter. Just the tools that keep a 90-day run on track.</p>
          </Reveal>

          <div className="feat-list">
            {features.map((f, i) => (
              <Reveal key={f.h} delay={i * 0.05}>
                <div className="feat-row">
                  <span className="idx">{String(i + 1).padStart(2, "0")}</span>
                  <h3>{f.h}</h3>
                  <p>{f.p}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── LEVELS ───────────────────────────── */}
      <section id="levels">
        <div className="wrap">
          <Reveal className="sec-head">
            <span className="label">Levels</span>
            <h2>Your average sets your rank.</h2>
            <p>Discipline scores roll up into a level, from Civilian to Elite.</p>
          </Reveal>

          <div className="ladder">
            {levels.map((l, i) => (
              <Reveal key={l.name} delay={i * 0.06}>
                <div className={`rung${l.peak ? " peak" : ""}`}>
                  <motion.div
                    className="bar"
                    initial={{ width: 0 }}
                    whileInView={{ width: l.w }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.8, delay: 0.1 + i * 0.06, ease: [0.22, 1, 0.36, 1] }}
                  />
                  <span className="rank">{l.rank}</span>
                  <span className="name">{l.name}</span>
                  <span className="tag">{l.tag}</span>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ─────────────────────── */}
      <section id="how">
        <div className="wrap">
          <Reveal className="sec-head">
            <span className="label">How it works</span>
            <h2>Three steps. Ninety days.</h2>
          </Reveal>
          <div className="steps">
            <Reveal delay={0} className="step">
              <div className="num">01</div>
              <h3>Set it up</h3>
              <p>Name your run, choose your focus areas, and write down why it matters.</p>
            </Reveal>
            <Reveal delay={0.08} className="step">
              <div className="num">02</div>
              <h3>Go Ghost</h3>
              <p>Select the apps that distract you. Start a session and they're blocked.</p>
            </Reveal>
            <Reveal delay={0.16} className="step">
              <div className="num">03</div>
              <h3>Check in</h3>
              <p>Log the morning and the night, score the day, and keep the streak going.</p>
            </Reveal>
          </div>
        </div>
      </section>

      {/* ── PRICING ──────────────────────────── */}
      <section id="pricing">
        <div className="wrap">
          <Reveal className="sec-head">
            <span className="label">Pricing</span>
            <h2>One subscription. Full access.</h2>
            <p>No free tier. Pick the plan that fits.</p>
          </Reveal>
          <div className="plans">
            <Reveal delay={0} className="plan">
              <div className="ptag" />
              <div className="period">Weekly</div>
              <div className="price">$2.99<span className="per"> /wk</span></div>
              <div className="note">3-day free trial</div>
            </Reveal>
            <Reveal delay={0.08} className="plan featured">
              <div className="ptag">Best value</div>
              <div className="period">Yearly</div>
              <div className="price">$29.99<span className="per"> /yr</span></div>
              <div className="note">Under $2.50 a month</div>
            </Reveal>
            <Reveal delay={0.16} className="plan">
              <div className="ptag" />
              <div className="period">Monthly</div>
              <div className="price">$5.99<span className="per"> /mo</span></div>
              <div className="note">Cancel anytime</div>
            </Reveal>
          </div>
          <Reveal>
            <p className="price-fine">
              Billed through your Apple ID. Subscriptions renew automatically unless cancelled at
              least 24 hours before the period ends. Manage or cancel anytime in your App Store settings.
            </p>
          </Reveal>
        </div>
      </section>

      {/* ── CTA ──────────────────────────────── */}
      <section id="download" className="band">
        <div className="wrap">
          <Reveal>
            <h2>START YOUR RUN.</h2>
            <p>Ninety days, beginning whenever you are.</p>
            <a className="btn" href="#">Download on the App Store</a>
          </Reveal>
        </div>
      </section>
    </>
  );
}
