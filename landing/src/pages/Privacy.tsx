import { Link } from "react-router-dom";
import Reveal from "../components/Reveal";

export default function Privacy() {
  return (
    <main className="doc">
      <div className="wrap narrow">
        <Reveal>
          <Link to="/" className="back">← Back</Link>
          <h1>Privacy Policy</h1>
          <div className="meta">Effective June 3, 2026 · Last Updated June 3, 2026</div>

          <p className="intro">
            This Privacy Policy describes how HXNDRD HOLDING LLC ("we," "us," or "our") collects,
            uses, and shares information about you when you use the 90DAYRUN mobile application ("App").
            90DAYRUN is built to keep your data on your device — we do not operate accounts, logins, or
            a personal-data server for the App.
          </p>

          <h2>1. Information We Collect</h2>

          <h3>a. Information You Create in the App</h3>
          <p>
            90DAYRUN stores the information you enter to run your 90-day challenge: your run name, your
            "why," chosen focus areas, goals, journal entries, reflections, daily morning and night
            check-ins, discipline scores, streak history, and streak-freeze usage.{" "}
            <strong>This information is stored locally on your device</strong> and is not transmitted to
            or stored on our servers.
          </p>

          <h3>b. Focus Session (Ghost Mode) Selections</h3>
          <p>
            When you use Ghost Mode to block distracting apps, you select apps, categories, or websites
            through Apple's Screen Time / Family Controls system. These selections are represented by{" "}
            <strong>opaque tokens managed entirely by Apple on your device</strong>. The App cannot see
            the real identities of the apps or sites you choose, and this information never leaves your
            device or reaches us.
          </p>

          <h3>c. Subscription and Purchase Information</h3>
          <p>
            When you purchase a subscription, the transaction is processed by Apple. We use RevenueCat to
            manage and validate subscriptions. In this process a pseudonymous app-user identifier and
            your purchase/transaction status are processed so we can confirm whether you have an active
            subscription. We do not receive your credit card number or full payment details.
          </p>

          <h3>d. Device and Technical Information</h3>
          <p>
            To operate the App and process in-app purchases, limited technical information (such as a
            device-generated identifier, app version, and subscription status) may be processed by Apple
            and RevenueCat. We do not collect analytics that personally identify you, and the App does not
            include third-party advertising trackers.
          </p>

          <div className="callout">
            <strong>No account required.</strong> 90DAYRUN does not use Sign in with Apple or any login.
            There is no microphone access, no voice recording, no camera, no location tracking, and no AI
            chat in the App.
          </div>

          <h2>2. How We Use Your Information</h2>
          <ul>
            <li>Provide, operate, and maintain the App and its features</li>
            <li>Save your run progress, streaks, check-ins, and journal entries on your device</li>
            <li>Enable Ghost Mode focus sessions through Apple Screen Time</li>
            <li>Process and validate your subscription and restore purchases</li>
            <li>Send the local reminder notifications you opt into</li>
            <li>Respond to your support requests</li>
            <li>Comply with legal obligations</li>
          </ul>

          <h2>3. Third-Party Services</h2>
          <p>We use the following third-party services, which may process limited data as described:</p>
          <table>
            <thead><tr><th>Service</th><th>Purpose</th></tr></thead>
            <tbody>
              <tr><td>Apple StoreKit</td><td>In-app purchases &amp; subscriptions</td></tr>
              <tr><td>RevenueCat</td><td>Subscription management &amp; receipt validation</td></tr>
              <tr><td>Apple Screen Time / Family Controls</td><td>On-device app blocking during Ghost Mode (no data sent to us)</td></tr>
            </tbody>
          </table>
          <p>
            We do not sell your personal information to third parties. We do not share your data with
            third parties for advertising purposes. Your use of Apple and RevenueCat services is also
            governed by their respective privacy policies.
          </p>

          <h2>4. Data Storage and Security</h2>
          <p>
            Your personal content — runs, check-ins, journal entries, scores, and streaks — is stored
            locally on your device. Subscription validation data handled by Apple and RevenueCat is
            transmitted securely using encryption in transit (HTTPS/TLS). No method of transmission or
            electronic storage is 100% secure, but we take reasonable measures to protect your information.
          </p>

          <h2>5. Data Retention and Deletion</h2>
          <p>
            Because your App content lives on your device, you can delete it at any time by clearing it
            within the App or by <strong>deleting the App</strong>, which permanently removes all locally
            stored data. Subscription records held by Apple and RevenueCat are retained according to their
            policies and as needed for billing, tax, and legal purposes.
          </p>
          <p>
            To request deletion of any data associated with you that we may hold, contact us at{" "}
            <a href="mailto:admin@hxndrdholding.com">admin@hxndrdholding.com</a>. We will process verified
            requests within 30 days, except where retention is required by law.
          </p>

          <h2>6. Your Rights and Choices</h2>
          <ul>
            <li>Access the limited personal information we may hold about you</li>
            <li>Request correction of inaccurate information</li>
            <li>Delete your locally stored data by removing it in-app or uninstalling the App</li>
            <li>Revoke Screen Time access at any time via <em>Settings &gt; Screen Time</em></li>
            <li>Turn off notifications at any time via <em>Settings &gt; Notifications</em></li>
          </ul>

          <h2>7. Screen Time &amp; Family Controls</h2>
          <p>
            The App requests Screen Time (Family Controls) authorization solely to block the apps and
            categories you choose during focus sessions. This feature operates entirely on your device
            through Apple's framework. We never receive the list of apps you block. You can revoke this
            permission at any time in <em>Settings &gt; Screen Time</em>; doing so disables Ghost Mode
            blocking but does not affect your runs, check-ins, or journal entries.
          </p>

          <h2>8. Notifications</h2>
          <p>
            If you allow notifications, the App schedules local reminders (such as daily check-in prompts)
            on your device. These are generated on-device and you can disable them at any time in{" "}
            <em>Settings &gt; Notifications</em> or within the App.
          </p>

          <h2>9. Photo Library</h2>
          <p>
            If you choose to save a run card or weekly recap image, the App requests permission to add that
            image to your photo library. The App only adds images you explicitly save and does not read or
            access your existing photos.
          </p>

          <h2>10. Children's Privacy</h2>
          <p>
            The App is not directed to children under the age of 13. We do not knowingly collect personal
            information from children under 13. If we learn that we have collected such data, we will delete
            it promptly.
          </p>

          <h2>11. Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. We will notify you of significant changes by
            updating the "Last Updated" date above. Continued use of the App after changes constitutes your
            acceptance of the updated policy.
          </p>

          <h2>12. Contact Us</h2>
          <div className="contact-box">
            <strong>HXNDRD HOLDING LLC</strong><br />
            Email: <a href="mailto:admin@hxndrdholding.com">admin@hxndrdholding.com</a><br />
            32 N Gould St., Sheridan, WY 82801
          </div>

          <hr className="rule" />
          <Link to="/" className="back">← Back</Link>
        </Reveal>
      </div>
    </main>
  );
}
