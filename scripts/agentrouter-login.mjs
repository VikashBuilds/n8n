// AgentRouter Daily Login via GitHub OAuth
// Uses Playwright to perform real browser-based OAuth flow
import { chromium } from 'playwright';

const GH_USER_SESSION = process.env.GH_USER_SESSION;
const GH_USER_SESSION_SS = process.env.GH_USER_SESSION_SS || GH_USER_SESSION;
const GH_DOTCOM_USER = process.env.GH_DOTCOM_USER || '';

if (!GH_USER_SESSION) {
  console.error('❌ GH_USER_SESSION secret is not set!');
  process.exit(1);
}

async function dailyLogin() {
  console.log(`🔑 AgentRouter Daily Login — ${new Date().toISOString()}`);
  console.log('');

  // Random delay 10-60s to look natural
  const delay = Math.floor(Math.random() * 50) + 10;
  console.log(`⏳ Waiting ${delay}s (random delay)...`);
  await new Promise(r => setTimeout(r, delay * 1000));

  console.log('🚀 Launching browser...');
  const browser = await chromium.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-blink-features=AutomationControlled',
    ],
  });

  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
    viewport: { width: 1920, height: 1080 },
    locale: 'en-US',
    timezoneId: 'Asia/Kolkata',
  });

  // Set GitHub cookies so OAuth auto-authorizes without manual login
  const githubCookies = [
    {
      name: 'user_session',
      value: GH_USER_SESSION,
      domain: '.github.com',
      path: '/',
      httpOnly: true,
      secure: true,
      sameSite: 'Lax',
    },
    {
      name: '__Host-user_session_same_site',
      value: GH_USER_SESSION_SS,
      domain: 'github.com',
      path: '/',
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
    },
    {
      name: 'logged_in',
      value: 'yes',
      domain: '.github.com',
      path: '/',
      httpOnly: false,
      secure: true,
      sameSite: 'Lax',
    },
  ];

  // Add dotcom_user if provided (GitHub username)
  if (GH_DOTCOM_USER) {
    githubCookies.push({
      name: 'dotcom_user',
      value: GH_DOTCOM_USER,
      domain: '.github.com',
      path: '/',
      httpOnly: false,
      secure: true,
      sameSite: 'Lax',
    });
  }

  await context.addCookies(githubCookies);
  console.log('🍪 GitHub cookies loaded');

  const page = await context.newPage();

  try {
    // Step 1: Go to AgentRouter login page
    console.log('🌐 Navigating to AgentRouter login...');
    await page.goto('https://agentrouter.org/login', {
      waitUntil: 'networkidle',
      timeout: 30000,
    });

    // Take screenshot for debugging
    await page.screenshot({ path: '/tmp/ar_step1_login.png' });
    console.log('   📸 Screenshot: login page captured');

    // Step 2: Click "Continue with GitHub"
    console.log('🔗 Clicking "Continue with GitHub"...');
    
    // Find and click the GitHub login button
    const githubButton = page.locator('text=Continue with GitHub').first();
    
    if (await githubButton.isVisible({ timeout: 10000 })) {
      await githubButton.click();
      console.log('   ✅ GitHub button clicked');
    } else {
      // Try alternative selectors
      const altButton = page.locator('a:has-text("GitHub"), button:has-text("GitHub")').first();
      if (await altButton.isVisible({ timeout: 5000 })) {
        await altButton.click();
        console.log('   ✅ GitHub button clicked (alt selector)');
      } else {
        console.log('   ⚠️  Could not find GitHub login button');
        await page.screenshot({ path: '/tmp/ar_error_no_button.png' });
        throw new Error('GitHub login button not found');
      }
    }

    // Step 3: Wait for OAuth redirect flow to complete
    // GitHub should auto-authorize (app already approved) and redirect back
    console.log('⏳ Waiting for OAuth redirect...');
    
    try {
      // Wait for redirect back to AgentRouter (console/dashboard)
      await page.waitForURL(url => {
        const href = url.toString();
        return href.includes('/console') || 
               href.includes('/dashboard') || 
               (href.includes('agentrouter.org') && !href.includes('/login'));
      }, { timeout: 30000 });
      
      console.log(`   ✅ Redirected to: ${page.url()}`);
    } catch (navError) {
      // Check if we're on GitHub auth page (needs manual authorization)
      const currentUrl = page.url();
      console.log(`   ⚠️  Current URL: ${currentUrl}`);
      
      if (currentUrl.includes('github.com/login')) {
        console.log('   ❌ GitHub session expired! Please update GH_USER_SESSION secret.');
        await page.screenshot({ path: '/tmp/ar_error_gh_login.png' });
        throw new Error('GitHub session expired');
      }
      
      if (currentUrl.includes('github.com/login/oauth/authorize')) {
        // App needs re-authorization - click authorize button
        console.log('   🔄 GitHub asking for re-authorization...');
        const authorizeBtn = page.locator('button[name="authorize"], input[name="authorize"]').first();
        if (await authorizeBtn.isVisible({ timeout: 5000 })) {
          await authorizeBtn.click();
          await page.waitForURL(url => url.toString().includes('agentrouter.org'), { timeout: 20000 });
          console.log(`   ✅ Re-authorized! Redirected to: ${page.url()}`);
        } else {
          await page.screenshot({ path: '/tmp/ar_error_gh_auth.png' });
          throw new Error('Cannot find GitHub authorize button');
        }
      }
    }

    // Step 4: Verify we're logged in
    await page.screenshot({ path: '/tmp/ar_step2_dashboard.png' });
    
    const finalUrl = page.url();
    const pageContent = await page.content();
    
    if (finalUrl.includes('agentrouter.org') && !finalUrl.includes('/login')) {
      console.log('');
      console.log('✅ ✅ ✅  LOGIN SUCCESSFUL!');
      console.log(`   URL: ${finalUrl}`);
      console.log('   New session created via OAuth → credits should be applied!');
      
      // Try to find and log the credit balance if visible
      try {
        const balanceText = await page.locator('text=/\\$[\\d,.]+/').first().textContent({ timeout: 5000 });
        console.log(`   💰 Balance visible: ${balanceText}`);
      } catch {
        console.log('   💰 Balance element not found (might be on a different page)');
      }
    } else {
      console.log('');
      console.log('⚠️  Login may not have completed successfully');
      console.log(`   Final URL: ${finalUrl}`);
    }

    // Step 5: Visit console/token page for good measure
    console.log('');
    console.log('🌐 Visiting console pages to confirm session...');
    try {
      await page.goto('https://agentrouter.org/console/token', { 
        waitUntil: 'networkidle', 
        timeout: 15000 
      });
      console.log(`   Console/token: ${page.url()}`);
      
      if (!page.url().includes('/login')) {
        console.log('   ✅ Console accessible — session is active!');
      }
    } catch {
      console.log('   ⚠️  Could not access console page');
    }

  } catch (error) {
    console.error('');
    console.error(`❌ Error: ${error.message}`);
    await page.screenshot({ path: '/tmp/ar_error_final.png' }).catch(() => {});
    await browser.close();
    process.exit(1);
  }

  await browser.close();
  console.log('');
  console.log(`🎉 Daily login complete — ${new Date().toISOString()}`);
}

dailyLogin().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
