import { useState } from "react";
import { Link } from "react-router-dom";
import { AnimatePresence, motion } from "framer-motion";
import Reveal from "../components/Reveal";

const faqs: { q: string; a: JSX.Element }[] = [
  {
    q: "How do I cancel my subscription?",
    a: (
      <>
        Open the <strong>Settings</strong> app → tap your name → <strong>Subscriptions</strong> →{" "}
        <strong>90DAYRUN</strong> → <strong>Cancel Subscription</strong>. Cancellation takes effect at
        the end of your current billing period.
      </>
    ),
  },
  {
    q: "How do I request a refund?",
    a: (
      <>
        Refunds for App Store purchases are handled by Apple. Visit{" "}
        <a href="https://reportaproblem.apple.com">reportaproblem.apple.com</a> and sign in with your
        Apple ID to submit a refund request.
      </>
    ),
  },
  {
    q: "I was charged but I can't access the app.",
    a: (
      <>
        Open 90DAYRUN, go to <strong>Settings → Restore Purchases</strong>, and make sure you're signed
        into the same Apple ID you subscribed with. If that doesn't fix it, email{" "}
        <a href="mailto:hxndrd@gmail.com">hxndrd@gmail.com</a> with your Apple ID email and proof of
        purchase and we'll sort it out fast.
      </>
    ),
  },
  {
    q: "Ghost Mode isn't blocking my apps.",
    a: (
      <>
        Ghost Mode uses Apple Screen Time. Go to <strong>Settings → Screen Time</strong> and make sure
        90DAYRUN is allowed to use Screen Time. Reopen the app, re-select the apps or categories you want
        blocked, and start a session. If blocking still doesn't apply, restart your device and try again.
      </>
    ),
  },
  {
    q: "My runs, streaks, or journal entries are missing.",
    a: (
      <>
        90DAYRUN stores your data <strong>on your device</strong>, not in the cloud. If you deleted and
        reinstalled the app, or moved to a new device, that local data does not transfer and cannot be
        recovered. As long as the app stays installed, your progress is safe — don't delete it mid-run.
      </>
    ),
  },
  {
    q: "I'm not getting my daily check-in reminders.",
    a: (
      <>
        Go to <strong>Settings → Notifications → 90DAYRUN</strong> and make sure notifications are on.
        Confirm reminders are enabled inside the app, and that Focus / Do Not Disturb isn't silencing them.
      </>
    ),
  },
  {
    q: "My streak reset even though I checked in.",
    a: (
      <>
        Streaks are kept by completing your check-in each day; a missed day breaks the chain unless a streak
        freeze is applied. If you believe a streak was lost in error, email{" "}
        <a href="mailto:hxndrd@gmail.com">hxndrd@gmail.com</a> with the date and what happened and we'll look.
      </>
    ),
  },
  {
    q: "How do I delete my data?",
    a: (
      <>
        Your data lives on your device, so you can remove all of it by <strong>deleting the app</strong>. If
        you'd like us to delete any account-related records held by us or our subscription provider, email{" "}
        <a href="mailto:admin@hxndrdholding.com">admin@hxndrdholding.com</a> with the subject "Delete My Data"
        and we'll process it within 30 days.
      </>
    ),
  },
  {
    q: "Is 90DAYRUN a parental-control or therapy app?",
    a: (
      <>
        No. 90DAYRUN is a self-discipline tool — it helps <em>you</em> block your own distractions and run a
        90-day grind. It is not a parental-control, monitoring, or mental-health service. If you're in crisis,
        please call or text <strong>988</strong> (Suicide &amp; Crisis Lifeline).
      </>
    ),
  },
];

export default function Support() {
  const [open, setOpen] = useState<number | null>(0);

  return (
    <main className="doc">
      <div className="wrap narrow">
        <Reveal>
          <Link to="/" className="back">← Back</Link>
          <h1>Support</h1>
          <div className="meta">90DAYRUN · iOS</div>

          <p className="intro">
            Need help? Most issues are covered below. If yours isn't, email us and we'll get back within 24 hours.
          </p>

          <div className="contact-box">
            <strong>Contact</strong><br />
            Email: <a href="mailto:hxndrd@gmail.com">hxndrd@gmail.com</a><br />
            We respond within 24 hours.
          </div>

          <h2>FAQ</h2>
        </Reveal>

        <Reveal>
          <div className="faq">
            {faqs.map((f, i) => {
              const isOpen = open === i;
              return (
                <div className="item" key={f.q}>
                  <button className="q" onClick={() => setOpen(isOpen ? null : i)}>
                    <span>{f.q}</span>
                    <span className="sign">{isOpen ? "–" : "+"}</span>
                  </button>
                  <AnimatePresence initial={false}>
                    {isOpen && (
                      <motion.div
                        className="a"
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.28, ease: [0.22, 1, 0.36, 1] }}
                      >
                        <div className="a-inner">{f.a}</div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              );
            })}
          </div>
        </Reveal>

        <hr className="rule" />
        <Link to="/" className="back">← Back</Link>
      </div>
    </main>
  );
}
