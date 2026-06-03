import { Link } from "react-router-dom";
import Reveal from "../components/Reveal";

export default function Terms() {
  return (
    <main className="doc">
      <div className="wrap narrow">
        <Reveal>
          <Link to="/" className="back">← Back</Link>
          <h1>Terms of Use</h1>
          <div className="meta">Effective June 3, 2026 · Last Updated June 3, 2026</div>

          <p className="intro">
            Please read these Terms of Use ("Terms") carefully before using the 90DAYRUN mobile
            application ("App") operated by HXNDRD HOLDING LLC ("we," "us," or "our"). By downloading
            or using the App, you agree to be bound by these Terms. If you do not agree, do not use the App.
          </p>

          <h2>1. Eligibility</h2>
          <p>
            You must be at least 13 years of age to use this App. By using the App, you represent that you
            meet this requirement. If you are under 18, you represent that your parent or legal guardian has
            reviewed and agreed to these Terms on your behalf.
          </p>

          <h2>2. Your Data and the App</h2>
          <p>
            90DAYRUN does not require an account or login. The content you create — runs, goals, check-ins,
            journal entries, scores, and streaks — is stored locally on your device. You are responsible for
            your device and for any data you choose to save or share. Uninstalling the App permanently removes
            its locally stored data.
          </p>

          <h2>3. Subscriptions and Payments</h2>
          <p>
            Full access to 90DAYRUN requires an active subscription ("Subscription"). The App does not offer a
            free tier. By purchasing a Subscription, you agree to the following:
          </p>
          <ul>
            <li><strong>Billing.</strong> Subscriptions are billed through your Apple ID account at the rates displayed at the time of purchase.</li>
            <li><strong>Auto-Renewal.</strong> Subscriptions automatically renew at the end of each billing period unless cancelled at least 24 hours before the renewal date.</li>
            <li><strong>Free Trials.</strong> If a free trial is offered at the time of purchase, you will not be charged until the trial period ends. Cancel before the trial ends to avoid charges.</li>
            <li><strong>Cancellation.</strong> You may cancel at any time through your device's App Store settings (<em>Settings &gt; [Your Name] &gt; Subscriptions</em>). Cancellation takes effect at the end of the current billing period; no partial refunds are issued.</li>
            <li><strong>Price Changes.</strong> We reserve the right to change Subscription pricing. You will be notified in advance of any price changes as required by Apple.</li>
            <li><strong>No Refunds.</strong> All purchases are final. Refund requests are handled solely by Apple in accordance with Apple's purchase policies.</li>
          </ul>

          <h2>4. Screen Time &amp; App Blocking</h2>
          <p>
            The App's Ghost Mode feature uses Apple's Screen Time / Family Controls framework to block apps,
            categories, or websites you select during focus sessions. By enabling this feature, you authorize
            the App to apply these on-device restrictions. The blocking is enforced by Apple's system on your
            device; we do not control your device beyond the restrictions you configure, and you may disable
            the feature or revoke the permission at any time in <em>Settings &gt; Screen Time</em>. The App is a
            self-discipline tool and is not a parental-control or monitoring service.
          </p>

          <h2>5. User Content</h2>
          <p>
            You retain ownership of the content you create within the App (journal entries, goals, reflections,
            run notes). Because this content is stored on your device, you control it. You agree not to use the
            App to create or store content that is unlawful, infringing, or that violates the rights of others.
          </p>

          <h2>6. Acceptable Use</h2>
          <p>You agree not to:</p>
          <ul>
            <li>Reverse engineer, decompile, or disassemble the App</li>
            <li>Use the App to violate any applicable law or regulation</li>
            <li>Attempt to gain unauthorized access to any part of the App or its systems</li>
            <li>Use the App for any commercial purpose without our prior written consent</li>
            <li>Circumvent any subscription or paywall mechanism</li>
          </ul>

          <h2>7. Not Professional Advice</h2>
          <p>
            90DAYRUN is a productivity and self-discipline tool. It does not provide medical, mental health,
            legal, financial, or other professional advice, and it is not a substitute for professional care.
            If you are experiencing a personal or mental health crisis, please contact a qualified professional
            or, in the United States, call or text <strong>988</strong> (Suicide &amp; Crisis Lifeline).
          </p>

          <h2>8. Intellectual Property</h2>
          <p>
            The App and its original content, features, and functionality are owned by HXNDRD HOLDING LLC and
            are protected by applicable intellectual property laws. You may not reproduce, distribute, or create
            derivative works without our express written permission.
          </p>

          <h2>9. Third-Party Services</h2>
          <p>
            The App integrates with third-party services including the Apple App Store / StoreKit (for in-app
            purchases), RevenueCat (for subscription management), and Apple Screen Time / Family Controls (for
            on-device app blocking). Your use of these services is also subject to their respective terms of
            service and privacy policies.
          </p>

          <h2>10. Disclaimer of Warranties</h2>
          <p>
            The App is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, express
            or implied. We do not warrant that the App will be uninterrupted, error-free, or free of harmful
            components, or that app-blocking will be effective in every circumstance.
          </p>

          <h2>11. Limitation of Liability</h2>
          <p>
            To the maximum extent permitted by applicable law, HXNDRD HOLDING LLC shall not be liable for any
            indirect, incidental, special, consequential, or punitive damages, or any loss of profits, revenues,
            or data, whether incurred directly or indirectly, arising out of your use of or inability to use the App.
          </p>

          <h2>12. Termination</h2>
          <p>
            We reserve the right to terminate or suspend your access to the App at any time, with or without
            cause, with or without notice. Upon termination, your right to use the App ceases immediately.
          </p>

          <h2>13. Changes to These Terms</h2>
          <p>
            We may update these Terms from time to time. We will notify you of significant changes by updating
            the "Last Updated" date above. Continued use of the App after changes constitutes your acceptance of
            the updated Terms.
          </p>

          <h2>14. Governing Law</h2>
          <p>
            These Terms are governed by the laws of the State of Wyoming, United States, without regard to its
            conflict of law provisions.
          </p>

          <h2>15. Contact Us</h2>
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
